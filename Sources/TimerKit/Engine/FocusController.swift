import Foundation
import Observation
import SwiftData
import UserNotifications

@MainActor
public protocol PlatformTileUpdating: AnyObject {
    func updateTile(session: TimerSession?, remaining: TimeInterval)
}

@MainActor
@Observable
public final class FocusController {
    public let engine: TimerEngine
    public let scheduler: PomodoroScheduler

    public var selectedDuration: TimeInterval = 25 * 60
    public var taskTitle: String = ""
    public var isCapturePresented = false
    public var captureText = "" {
        didSet {
            updateDebouncedCaptureText()
        }
    }
    public private(set) var lastSavedMemo: Memo?
    public var captureError: String?

    private let detector = CaptureDetector()
    private let deviceID = DeviceIdentity.current
    private weak var platformTileUpdater: PlatformTileUpdating?
    private var debouncedCaptureText = ""
    private var advancedCompletedSegments = Set<UUID>()
    private var captureDetectionTask: Task<Void, Never>?

    public init(
        engine: TimerEngine = TimerEngine(),
        platformTileUpdater: PlatformTileUpdating? = nil
    ) {
        self.engine = engine
        self.scheduler = PomodoroScheduler(engine: engine)
        self.platformTileUpdater = platformTileUpdater
    }

    public var currentState: TactState {
        isCapturePresented ? .capture : TactState.from(session: engine.activeSession)
    }

    public var activeSession: TimerSession? {
        engine.activeSession
    }

    public var isRunning: Bool {
        activeSession?.state == .running
    }

    public var canResume: Bool {
        activeSession?.state == .paused
    }

    public var primaryActionTitle: String {
        if isRunning { return "Pause" }
        if canResume { return "Resume" }
        return "Start"
    }

    public var statusText: String {
        guard let session = activeSession else { return "Ready to focus" }
        switch session.state {
        case .running:
            switch session.kind {
            case .standalone: return "Timer running"
            case .pomodoroWork: return scheduler.currentPomodoro?.taskTitle ?? "Pomodoro focus"
            case .pomodoroShortBreak: return "Short break"
            case .pomodoroLongBreak: return "Long break"
            }
        case .paused:
            return "Paused"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }

    public var contextTitle: String {
        guard let session = activeSession else { return "No active timer" }
        if session.kind == .standalone { return "Focus timer" }
        return scheduler.currentPomodoro?.taskTitle ?? "Pomodoro"
    }

    public var captureContextText: String {
        guard let session = activeSession else { return "No active timer" }
        let elapsed = Self.formatElapsed(session.elapsed(at: engine.lastTickAt))
        return "During: \(contextTitle) · \(elapsed) in"
    }

    public var menuBarTitle: String {
        guard let session = activeSession, !session.isFinished else { return "Tact" }
        return Self.formatTime(session.remaining(at: engine.lastTickAt))
    }

    public var progress: Double {
        guard let session = activeSession, session.duration > 0 else { return 0 }
        return min(1, max(0, session.elapsed(at: engine.lastTickAt) / session.duration))
    }

    public var detections: [Detection] {
        detector.detect(debouncedCaptureText)
    }

    public func startStandalone(modelContext: ModelContext) {
        let session = TimerSession(
            duration: selectedDuration,
            initiatedByDeviceID: deviceID
        )
        modelContext.insert(session)
        try? modelContext.save()
        engine.start(session)
        updatePlatformTile()
        scheduleCompletionNotification(for: session)
    }

    public func startPomodoro(modelContext: ModelContext) {
        let trimmedTask = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let pomodoro = scheduler.start(
            taskTitle: trimmedTask.isEmpty ? nil : trimmedTask,
            deviceID: deviceID
        )
        modelContext.insert(pomodoro)
        if let activeSession {
            modelContext.insert(activeSession)
            updatePlatformTile()
            scheduleCompletionNotification(for: activeSession)
        }
        try? modelContext.save()
    }

    public func togglePrimary(modelContext: ModelContext) {
        if isRunning {
            let sessionID = activeSession?.id
            if let sessionID {
                cancelPendingNotification(for: sessionID)
            }
            engine.pause()
        } else if canResume {
            engine.resume()
            if let activeSession {
                scheduleCompletionNotification(for: activeSession)
            }
        } else {
            startStandalone(modelContext: modelContext)
        }
        updatePlatformTile()
        try? modelContext.save()
    }

    public func cancel(modelContext: ModelContext) {
        let sessionID = activeSession?.id
        if let sessionID {
            cancelPendingNotification(for: sessionID)
        }
        scheduler.cancel()
        engine.cancel()
        updatePlatformTile()
        try? modelContext.save()
    }

    public func presentCapture() {
        captureText = ""
        captureError = nil
        isCapturePresented = true
    }

    public func dismissCapture() {
        captureText = ""
        captureError = nil
        isCapturePresented = false
    }

    public func saveCapture(modelContext: ModelContext) {
        let trimmed = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            dismissCapture()
            return
        }

        do {
            let store = MemoStore(modelContext: modelContext, detector: detector)
            lastSavedMemo = try store.save(
                content: trimmed,
                currentPomodoro: scheduler.currentPomodoro,
                timeIntoCurrentSession: activeSession?.elapsed(at: engine.lastTickAt)
            )
            dismissCapture()
        } catch {
            captureError = "Could not save memo"
        }
    }

    public func advancePomodoroIfNeeded(modelContext: ModelContext) {
        guard
            let completed = activeSession,
            completed.state == .completed,
            completed.kind != .standalone,
            !advancedCompletedSegments.contains(completed.id)
        else { return }

        advancedCompletedSegments.insert(completed.id)
        scheduler.segmentDidComplete(deviceID: deviceID)

        if let activeSession {
            modelContext.insert(activeSession)
            updatePlatformTile()
            scheduleCompletionNotification(for: activeSession)
        } else {
            updatePlatformTile()
        }
        try? modelContext.save()
    }

    public func refreshPlatformTile() {
        updatePlatformTile()
    }

    public static func formatTime(_ time: TimeInterval) -> String {
        let clamped = max(0, Int(time.rounded(.up)))
        let minutes = clamped / 60
        let seconds = clamped % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private static func formatElapsed(_ time: TimeInterval) -> String {
        let minutes = max(0, Int(time.rounded(.down))) / 60
        if minutes == 1 { return "1 min" }
        return "\(minutes) min"
    }

    private func scheduleCompletionNotification(for session: TimerSession) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }

        let content = UNMutableNotificationContent()
        content.title = "Tact"
        content.body = session.kind == .standalone ? "Timer complete" : "Pomodoro segment complete"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, session.remaining(at: Date())),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: session.id.uuidString,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    private func cancelPendingNotification(for sessionID: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [sessionID.uuidString])
    }

    private func updateDebouncedCaptureText() {
        captureDetectionTask?.cancel()

        let text = captureText
        guard !text.isEmpty else {
            debouncedCaptureText = ""
            return
        }

        captureDetectionTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
            } catch {
                return
            }

            await MainActor.run {
                guard let self, self.captureText == text else { return }
                self.debouncedCaptureText = text
            }
        }
    }

    private func updatePlatformTile() {
        let session = activeSession
        let remaining = session?.remaining(at: engine.lastTickAt) ?? 0
        platformTileUpdater?.updateTile(session: session, remaining: remaining)
    }
}
