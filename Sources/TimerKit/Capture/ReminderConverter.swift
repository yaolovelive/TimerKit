// ReminderConverter.swift
//
// Turns a dated memo into a clean reminder draft. EventKit submission is
// available only to the macOS and iOS app targets.

import Foundation

public struct ReminderDraft: Sendable, Equatable {
    public let title: String
    public let dueDate: Date

    public init(title: String, dueDate: Date) {
        self.title = title
        self.dueDate = dueDate
    }
}

public enum ReminderConversionError: Error, Equatable, Sendable {
    case noDueDate
    case accessDenied
}

public enum ReminderConverter {
    /// Builds the platform-independent reminder payload from a memo's date
    /// detection. Passing detections in makes this transformation deterministic
    /// and straightforward to test.
    public static func draft(
        content: String,
        detections: [Detection]
    ) throws -> ReminderDraft {
        guard let dateDetection = detections.first(where: {
            if case .date = $0.kind { return true }
            return false
        }) else {
            throw ReminderConversionError.noDueDate
        }

        guard case let .date(dueDate) = dateDetection.kind else {
            throw ReminderConversionError.noDueDate
        }

        let withoutDate = content.replacingCharacters(in: dateDetection.range, with: "")
        let title = withoutDate
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ",，。;；、"))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return ReminderDraft(title: title.isEmpty ? "Reminder" : title, dueDate: dueDate)
    }

    /// Builds a draft using the same detector used when the memo was saved.
    public static func draft(for memo: Memo, detector: CaptureDetector = .init()) throws -> ReminderDraft {
        try draft(content: memo.content, detections: detector.detect(memo.content))
    }
}

#if os(iOS) || os(macOS)
import EventKit

public extension ReminderConverter {
    /// Requests Reminders access and saves the memo as an EventKit reminder.
    /// The returned UUID is stored in Memo.convertedToTaskID by the caller.
    @MainActor
    static func saveToSystemReminders(_ memo: Memo) async throws -> UUID {
        let store = EKEventStore()
        var status = EKEventStore.authorizationStatus(for: .reminder)
        if status == .notDetermined {
            try await store.requestFullAccessToReminders()
            status = EKEventStore.authorizationStatus(for: .reminder)
        }
        guard status == .fullAccess else {
            throw ReminderConversionError.accessDenied
        }

        let draft = try draft(for: memo)
        let reminder = EKReminder(eventStore: store)
        reminder.title = draft.title
        reminder.calendar = store.defaultCalendarForNewReminders()
        reminder.dueDateComponents = Calendar.current.dateComponents(
            [.calendar, .year, .month, .day, .hour, .minute],
            from: draft.dueDate
        )
        try store.save(reminder, commit: true)
        return UUID()
    }
}
#endif
