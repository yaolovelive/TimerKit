// PomodoroSession.swift
//
// A pomodoro session is a sequence of TimerSessions (work + breaks)
// bound to an optional task. Config is snapshotted at start so changing
// preferences later doesn't retroactively rewrite history.

import Foundation
import SwiftData

public struct PomodoroConfig: Codable, Sendable, Hashable {
    public var workDuration: TimeInterval         // default 25 * 60
    public var shortBreakDuration: TimeInterval   // default 5 * 60
    public var longBreakDuration: TimeInterval    // default 15 * 60
    public var roundsBeforeLongBreak: Int         // default 4
    public var autoStartNextSegment: Bool         // default true

    public static let standard = PomodoroConfig(
        workDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        roundsBeforeLongBreak: 4,
        autoStartNextSegment: true
    )

    public init(
        workDuration: TimeInterval,
        shortBreakDuration: TimeInterval,
        longBreakDuration: TimeInterval,
        roundsBeforeLongBreak: Int,
        autoStartNextSegment: Bool
    ) {
        self.workDuration = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.roundsBeforeLongBreak = roundsBeforeLongBreak
        self.autoStartNextSegment = autoStartNextSegment
    }
}

@Model
public final class PomodoroSession {
    public var id: UUID = UUID()
    public var startedAt: Date = Date()
    public var completedAt: Date?

    /// Optional task label, e.g. "Writing dev spec".
    public var taskTitle: String?

    /// Frozen at start time — see file header for rationale.
    public var configSnapshot: PomodoroConfig = PomodoroConfig.standard

    // Must be optional for CloudKit compatibility (CloudKit requires all relationships optional).
    @Relationship(deleteRule: .cascade, inverse: \TimerSession.pomodoro)
    public var rounds: [TimerSession]?

    @Relationship public var tag: Tag?

    public init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        taskTitle: String? = nil,
        configSnapshot: PomodoroConfig = .standard,
        rounds: [TimerSession] = [],
        tag: Tag? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.taskTitle = taskTitle
        self.configSnapshot = configSnapshot
        self.rounds = rounds
        self.tag = tag
    }

    public var completedRoundCount: Int {
        (rounds ?? []).filter { $0.kind == .pomodoroWork && $0.state == .completed }.count
    }

    public var interruptedRoundCount: Int {
        (rounds ?? []).filter { $0.kind == .pomodoroWork && $0.state == .cancelled }.count
    }
}
