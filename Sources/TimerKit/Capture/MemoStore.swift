// MemoStore.swift
//
// Owns memo persistence. Attaches CapturedContext at save time by
// asking TimerEngine and PomodoroScheduler what's currently active.

import Foundation
import SwiftData

@MainActor
public final class MemoStore {
    private let modelContext: ModelContext
    private let detector: CaptureDetector

    public init(modelContext: ModelContext, detector: CaptureDetector = .init()) {
        self.modelContext = modelContext
        self.detector = detector
    }

    /// Save a memo with auto-detected type and the currently active
    /// pomodoro context, if any.
    @discardableResult
    public func save(
        content: String,
        currentPomodoro: PomodoroSession?,
        timeIntoCurrentSession: TimeInterval?
    ) throws -> Memo {
        let detections = detector.detect(content)
        let type = detections.primaryMemoType
        let context = CapturedContext(
            pomodoroID: currentPomodoro?.id,
            taskTitle: currentPomodoro?.taskTitle,
            tagName: currentPomodoro?.tag?.name,
            timeIntoSession: timeIntoCurrentSession
        )

        let memo = Memo(
            content: content,
            detectedType: type,
            capturedContext: currentPomodoro != nil ? context : nil,
            tag: currentPomodoro?.tag
        )
        modelContext.insert(memo)
        try modelContext.save()
        return memo
    }

    /// Auto-archive memos older than 30 days that are unpinned and
    /// untouched. Call from a periodic BGAppRefreshTask.
    public func archiveStale(cutoff: Date = Date().addingTimeInterval(-30 * 86400)) throws {
        // TODO: implement with FetchDescriptor + modelContext.delete or
        // a separate `archived` flag (preferred — preserves data, removes
        // from inbox queries).
    }
}
