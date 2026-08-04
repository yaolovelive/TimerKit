import Foundation
import Testing
@testable import TimerKit

@Suite("Check-in scheduler")
struct CheckInSchedulerTests {
    @Test("scheduled date delegates to delay")
    func scheduledDateDelegatesToDelay() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(CheckInScheduler.scheduledDate(for: .twoHours, from: now) == now.addingTimeInterval(2 * 60 * 60))
    }

    @Test("mark done records completion")
    func markDoneRecordsCompletion() {
        let scheduled = Date(timeIntervalSince1970: 1_700_000_000)
        let completed = scheduled.addingTimeInterval(60)
        let memo = Memo(content: "Check the bug")
        memo.checkInReminder = CheckInReminder(scheduledFor: scheduled)

        CheckInScheduler.applyMarkDone(to: memo, at: completed)

        #expect(memo.checkInReminder?.scheduledFor == scheduled)
        #expect(memo.checkInReminder?.completedAt == completed)
    }

    @Test("snooze replaces the schedule and clears completion")
    func snoozeReplacesSchedule() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let memo = Memo(content: "Check the bug")
        memo.checkInReminder = CheckInReminder(
            scheduledFor: now,
            completedAt: now
        )

        CheckInScheduler.applySnooze(to: memo, delay: .thirtyMinutes, from: now)

        #expect(memo.checkInReminder?.scheduledFor == now.addingTimeInterval(30 * 60))
        #expect(memo.checkInReminder?.completedAt == nil)
    }
}
