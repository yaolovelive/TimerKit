// PomodoroScheduler.swift
//
// Walks a PomodoroSession through its work/break sequence. Calls
// TimerEngine to actually run each segment. Owns the auto-transition
// behavior between segments.

import Foundation
import Observation

@Observable
public final class PomodoroScheduler {
    private let engine: TimerEngine
    public private(set) var currentPomodoro: PomodoroSession?
    public private(set) var currentRoundIndex: Int = 0

    public init(engine: TimerEngine) {
        self.engine = engine
    }

    // MARK: - Public API

    /// Start a fresh pomodoro session with the given config and task.
    /// Pulls the active task/tag context into all child TimerSessions.
    public func start(
        config: PomodoroConfig = .standard,
        taskTitle: String? = nil,
        tag: Tag? = nil,
        deviceID: String
    ) -> PomodoroSession {
        let session = PomodoroSession(
            taskTitle: taskTitle,
            configSnapshot: config,
            tag: tag
        )
        currentPomodoro = session
        currentRoundIndex = 0
        startNextSegment(deviceID: deviceID)
        return session
    }

    /// Called when the current segment completes. If autoStartNextSegment
    /// is true, immediately starts the next; otherwise pauses for the
    /// user to tap "Start break/work".
    public func segmentDidComplete(deviceID: String) {
        guard let pomodoro = currentPomodoro else { return }
        currentRoundIndex += 1

        if pomodoro.configSnapshot.autoStartNextSegment {
            startNextSegment(deviceID: deviceID)
        }
    }

    /// Cancel the current pomodoro entirely. Increments pollution count.
    public func cancel() {
        guard let pomodoro = currentPomodoro else { return }
        pomodoro.completedAt = nil
        engine.cancel()
        currentPomodoro = nil
        currentRoundIndex = 0
    }

    // MARK: - Internal

    private func startNextSegment(deviceID: String) {
        guard let pomodoro = currentPomodoro else { return }
        let config = pomodoro.configSnapshot

        let kind = nextSegmentKind(for: currentRoundIndex, config: config)
        let duration: TimeInterval = {
            switch kind {
            case .pomodoroWork: return config.workDuration
            case .pomodoroShortBreak: return config.shortBreakDuration
            case .pomodoroLongBreak: return config.longBreakDuration
            case .standalone: return config.workDuration
            }
        }()

        let segment = TimerSession(
            duration: duration,
            kind: kind,
            initiatedByDeviceID: deviceID,
            pomodoro: pomodoro,
            tag: pomodoro.tag
        )
        if pomodoro.rounds == nil { pomodoro.rounds = [] }
        pomodoro.rounds?.append(segment)
        engine.start(segment)
    }

    /// Pomodoro pattern: W B W B W B W LB (W B W B ...) where LB
    /// triggers every `roundsBeforeLongBreak` work segments.
    private func nextSegmentKind(for index: Int, config: PomodoroConfig) -> SessionKind {
        // Even indices = work, odd = break.
        if index % 2 == 0 {
            return .pomodoroWork
        } else {
            // After the Nth work segment, the following break is a long one.
            let workSegmentsCompleted = (index + 1) / 2
            return workSegmentsCompleted % config.roundsBeforeLongBreak == 0
                ? .pomodoroLongBreak
                : .pomodoroShortBreak
        }
    }
}
