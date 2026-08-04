import Foundation
import Testing
@testable import TimerKit

@Suite("Check-in delay")
struct CheckInDelayTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Taipei")!
        return calendar
    }

    @Test("calculates each delay")
    func calculatesEachDelay() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        #expect(CheckInDelay.thirtyMinutes.fireDate(from: now, calendar: calendar) == now.addingTimeInterval(30 * 60))
        #expect(CheckInDelay.twoHours.fireDate(from: now, calendar: calendar) == now.addingTimeInterval(2 * 60 * 60))

        let expectedTomorrow = calendar.date(byAdding: .day, value: 1, to: now)
        #expect(CheckInDelay.tomorrow.fireDate(from: now, calendar: calendar) == expectedTomorrow)
    }

    @Test("tomorrow crosses midnight by calendar day")
    func tomorrowCrossesMidnight() {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = 2026
        components.month = 8
        components.day = 4
        components.hour = 23
        components.minute = 50
        let now = calendar.date(from: components)!

        let result = CheckInDelay.tomorrow.fireDate(from: now, calendar: calendar)
        let resultComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: result)
        #expect(resultComponents.year == 2026)
        #expect(resultComponents.month == 8)
        #expect(resultComponents.day == 5)
        #expect(resultComponents.hour == 23)
        #expect(resultComponents.minute == 50)
    }
}
