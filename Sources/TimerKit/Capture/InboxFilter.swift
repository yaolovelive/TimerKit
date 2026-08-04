// InboxFilter.swift
//
// Pure Inbox grouping and filtering logic shared by the macOS and iOS views.

import Foundation

public enum InboxGroup: String, CaseIterable, Hashable, Sendable {
    case all
    case reminders
    case links
    case questions

    fileprivate func includes(_ memo: Memo) -> Bool {
        switch self {
        case .all: return true
        case .reminders: return memo.detectedType == .reminder
        case .links: return memo.detectedType == .url
        case .questions: return memo.detectedType == .question
        }
    }
}

public enum InboxFilter {
    /// Returns active memos in reverse chronological order, optionally scoped
    /// to a smart group and/or the pomodoro that captured them.
    public static func filter(
        _ memos: [Memo],
        group: InboxGroup = .all,
        pomodoroID: UUID? = nil
    ) -> [Memo] {
        memos
            .filter { !$0.archived }
            .filter { group.includes($0) }
            .filter { memo in
                guard let pomodoroID else { return true }
                return memo.capturedContext?.pomodoroID == pomodoroID
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Returns the three smart groups, with the same ordering as `filter`.
    public static func grouped(
        _ memos: [Memo],
        pomodoroID: UUID? = nil
    ) -> [InboxGroup: [Memo]] {
        Dictionary(uniqueKeysWithValues: InboxGroup.allCases
            .filter { $0 != .all }
            .map { ($0, filter(memos, group: $0, pomodoroID: pomodoroID)) })
    }
}
