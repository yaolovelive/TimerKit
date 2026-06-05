// Memo.swift, Tag.swift, DailyStats.swift
//
// The remaining SwiftData entities. Kept in one file because they're
// small and naturally cohesive.

import Foundation
import SwiftData

// MARK: - Memo

public enum MemoType: String, Codable, Sendable {
    case plain
    case reminder    // contains a parseable date/time
    case todo        // starts with "- " or "todo:"
    case url         // contains a URL
    case contact     // contains a phone or email
    case question    // ends with "?"
    case reflection  // saved as a response to a weekly report question
}

@Model
public final class Memo {
    public var id: UUID = UUID()
    public var createdAt: Date = Date()
    public var content: String = ""
    public var detectedType: MemoType = MemoType.plain

    /// If this memo was converted to a system reminder via EventKit.
    public var convertedToTaskID: UUID?

    /// Snapshot of the focus context active at the moment of capture.
    public var capturedContext: CapturedContext?

    @Relationship public var tag: Tag?

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        content: String,
        detectedType: MemoType = .plain,
        convertedToTaskID: UUID? = nil,
        capturedContext: CapturedContext? = nil,
        tag: Tag? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.content = content
        self.detectedType = detectedType
        self.convertedToTaskID = convertedToTaskID
        self.capturedContext = capturedContext
        self.tag = tag
    }
}

/// Frozen snapshot of what the user was doing when a memo was captured.
/// Read-only after creation. See docs/03-features.md (capture).
public struct CapturedContext: Codable, Sendable, Hashable {
    public let pomodoroID: UUID?
    public let taskTitle: String?
    public let tagName: String?
    public let timeIntoSession: TimeInterval?

    public init(
        pomodoroID: UUID? = nil,
        taskTitle: String? = nil,
        tagName: String? = nil,
        timeIntoSession: TimeInterval? = nil
    ) {
        self.pomodoroID = pomodoroID
        self.taskTitle = taskTitle
        self.tagName = tagName
        self.timeIntoSession = timeIntoSession
    }
}

// MARK: - Tag

public enum TagColor: String, Codable, Sendable, CaseIterable {
    case slate, sky, teal, sage, amber, coral, plum, blush
}

@Model
public final class Tag {
    public var id: UUID = UUID()
    public var name: String = ""
    public var color: TagColor = TagColor.slate
    public var createdAt: Date = Date()

    // Inverse relationships required for CloudKit compatibility.
    @Relationship(inverse: \TimerSession.tag) public var timerSessions: [TimerSession]?
    @Relationship(inverse: \Memo.tag) public var memos: [Memo]?
    @Relationship(inverse: \PomodoroSession.tag) public var pomodoroSessions: [PomodoroSession]?

    public init(
        id: UUID = UUID(),
        name: String,
        color: TagColor = .slate,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
}

// MARK: - DailyStats (pre-aggregated)

/// Per-day rollup, recomputed at the end of each completed session.
/// Read path for statistics views — avoids scanning all TimerSessions.
@Model
public final class DailyStats {
    /// Start-of-day (local time, normalized to UTC midnight of that local day).
    public var date: Date = Date()

    public var focusMinutes: Int = 0
    public var completedPomodoros: Int = 0
    public var pollutedPomodoros: Int = 0
    public var memoCount: Int = 0
    public var topTagID: UUID?
    public var lastUpdated: Date = Date()

    public init(
        date: Date,
        focusMinutes: Int = 0,
        completedPomodoros: Int = 0,
        pollutedPomodoros: Int = 0,
        memoCount: Int = 0,
        topTagID: UUID? = nil,
        lastUpdated: Date = Date()
    ) {
        self.date = date
        self.focusMinutes = focusMinutes
        self.completedPomodoros = completedPomodoros
        self.pollutedPomodoros = pollutedPomodoros
        self.memoCount = memoCount
        self.topTagID = topTagID
        self.lastUpdated = lastUpdated
    }
}
