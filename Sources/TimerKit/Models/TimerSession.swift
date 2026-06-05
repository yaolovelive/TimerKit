// TimerSession.swift
//
// The atomic unit of timing. Every standalone timer AND every segment
// inside a pomodoro is a TimerSession. Cross-device sync transports
// these records via CloudKit; each device computes its own displayed
// time from startedAt + duration + pauseHistory.
//
// IMPORTANT: this is the CloudKit sync surface. Adding non-optional
// fields after launch is a breaking change. Add optional fields only.
// See docs/02-architecture.md.

import Foundation
import SwiftData

@Model
public final class TimerSession {
    public var id: UUID = UUID()

    /// UTC absolute timestamp. Single source of truth for cross-device display.
    public var startedAt: Date = Date()

    /// Planned duration in seconds. Independent of state.
    public var duration: TimeInterval = 0

    public var state: SessionState = SessionState.running

    public var kind: SessionKind = SessionKind.standalone

    /// Pause/resume history. Sum of pause durations is subtracted from
    /// elapsed time when computing what to show on screen.
    public var pauseHistory: [PauseRecord] = []

    /// Stable identifier of the device that started this session.
    public var initiatedByDeviceID: String = ""

    /// Optional binding to a parent pomodoro session.
    @Relationship public var pomodoro: PomodoroSession?

    /// Optional categorization.
    @Relationship public var tag: Tag?

    public init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        duration: TimeInterval,
        state: SessionState = .running,
        kind: SessionKind = .standalone,
        pauseHistory: [PauseRecord] = [],
        initiatedByDeviceID: String,
        pomodoro: PomodoroSession? = nil,
        tag: Tag? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.duration = duration
        self.state = state
        self.kind = kind
        self.pauseHistory = pauseHistory
        self.initiatedByDeviceID = initiatedByDeviceID
        self.pomodoro = pomodoro
        self.tag = tag
    }

    // MARK: - Computed

    /// Total time spent paused, summed across all pause records.
    public var totalPauseDuration: TimeInterval {
        pauseHistory.reduce(0) { $0 + $1.duration }
    }

    /// Elapsed working time as of `now`.
    public func elapsed(at now: Date = Date()) -> TimeInterval {
        let raw = now.timeIntervalSince(startedAt)
        return max(0, raw - totalPauseDuration)
    }

    /// Time remaining until completion as of `now`.
    public func remaining(at now: Date = Date()) -> TimeInterval {
        max(0, duration - elapsed(at: now))
    }

    public var isFinished: Bool {
        state == .completed || state == .cancelled
    }
}
