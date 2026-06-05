// SessionState.swift
//
// The lifecycle states of any timer session, standalone or pomodoro.

import Foundation

public enum SessionState: String, Codable, Sendable {
    case running
    case paused
    case completed
    case cancelled
}

public enum SessionKind: String, Codable, Sendable {
    case standalone           // a one-off timer ("boil egg, 5 min")
    case pomodoroWork         // a work segment inside a PomodoroSession
    case pomodoroShortBreak   // a short break between work segments
    case pomodoroLongBreak    // a long break after a configured number of work segments
}

public struct PauseRecord: Codable, Sendable, Hashable {
    public let pausedAt: Date
    public var resumedAt: Date?

    public init(pausedAt: Date, resumedAt: Date? = nil) {
        self.pausedAt = pausedAt
        self.resumedAt = resumedAt
    }

    public var duration: TimeInterval {
        guard let resumedAt else { return Date().timeIntervalSince(pausedAt) }
        return resumedAt.timeIntervalSince(pausedAt)
    }
}
