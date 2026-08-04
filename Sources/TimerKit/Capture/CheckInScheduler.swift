import Foundation
import SwiftData
import UserNotifications

public enum CheckInScheduler {
    public static let categoryIdentifier = "MEMO_CHECKIN"
    public static let markDoneActionIdentifier = "MARK_DONE"
    public static let snoozeActionIdentifier = "SNOOZE"

    public static func scheduledDate(
        for delay: CheckInDelay,
        from now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        delay.fireDate(from: now, calendar: calendar)
    }

    public static func applyMarkDone(to memo: Memo, at date: Date = Date()) {
        guard var reminder = memo.checkInReminder else { return }
        reminder.completedAt = date
        memo.checkInReminder = reminder
    }

    public static func applySnooze(
        to memo: Memo,
        delay: CheckInDelay = .thirtyMinutes,
        from now: Date = Date(),
        calendar: Calendar = .current
    ) {
        memo.checkInReminder = CheckInReminder(
            scheduledFor: scheduledDate(for: delay, from: now, calendar: calendar)
        )
    }

    /// Register the actions once during each app's launch.
    public static func registerCategory() {
        let markDone = UNNotificationAction(
            identifier: markDoneActionIdentifier,
            title: "已完成",
            options: []
        )
        let snooze = UNNotificationAction(
            identifier: snoozeActionIdentifier,
            title: "还没，再提醒我",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [markDone, snooze],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    @MainActor
    public static func scheduleCheckIn(
        for memo: Memo,
        delay: CheckInDelay,
        modelContext: ModelContext,
        from now: Date = Date(),
        calendar: Calendar = .current
    ) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }

        let scheduledFor = scheduledDate(for: delay, from: now, calendar: calendar)
        memo.checkInReminder = CheckInReminder(scheduledFor: scheduledFor)
        try? modelContext.save()

        let content = UNMutableNotificationContent()
        content.title = "Tact 快速提醒"
        content.body = String(memo.content.prefix(120))
        content.categoryIdentifier = categoryIdentifier
        content.sound = .default
        content.userInfo = ["memoID": memo.id.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, scheduledFor.timeIntervalSinceNow),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "checkin-\(memo.id.uuidString)",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    @MainActor
    public static func handleAction(
        identifier: String,
        memoID: UUID,
        modelContext: ModelContext
    ) throws {
        var descriptor = FetchDescriptor<Memo>(
            predicate: #Predicate { memo in memo.id == memoID }
        )
        descriptor.fetchLimit = 1
        guard let memo = try modelContext.fetch(descriptor).first else { return }

        switch identifier {
        case markDoneActionIdentifier:
            applyMarkDone(to: memo)
            try modelContext.save()
        case snoozeActionIdentifier:
            applySnooze(to: memo)
            try modelContext.save()
            scheduleCheckIn(for: memo, delay: .thirtyMinutes, modelContext: modelContext)
        default:
            break
        }
    }
}
