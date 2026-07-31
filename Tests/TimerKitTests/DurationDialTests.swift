// DurationDialTests.swift

import Foundation
import Testing
@testable import TimerKit

struct DurationDialTests {
    @Test func snapsToNearestFiveMinuteDetent() {
        #expect(DurationDial.snap(26 * 60) == 25 * 60)
        #expect(DurationDial.snap(28 * 60) == 30 * 60)
    }

    @Test func leavesExactDetentUnchanged() {
        #expect(DurationDial.snap(25 * 60) == 25 * 60)
    }

    @Test func clampsBelowMinimumUpToFiveMinutes() {
        #expect(DurationDial.snap(0) == 5 * 60)
        #expect(DurationDial.snap(-90) == 5 * 60)
    }

    @Test func clampsAboveMaximumDownToTwoHours() {
        #expect(DurationDial.snap(999 * 60) == 120 * 60)
    }

    @Test func roundTripsThroughCrownMinutes() {
        let duration = DurationDial.duration(fromMinutes: 45)
        #expect(duration == 45 * 60)
        #expect(DurationDial.minutes(from: duration) == 45)
    }
}
