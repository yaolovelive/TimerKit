// HapticPatternTests.swift

import Foundation
import Testing
@testable import TimerKit

struct HapticPatternTests {
    @Test func startingFocusFromIdleTapsOnce() {
        #expect(HapticEvent.forTransition(from: .idle, to: .focus) == .sessionStart)
    }

    @Test func finishingWorkAnnouncesTheBreak() {
        #expect(HapticEvent.forTransition(from: .focus, to: .shortBreak) == .workComplete)
        #expect(HapticEvent.forTransition(from: .focus, to: .longBreak) == .workComplete)
    }

    @Test func returningFromBreakUsesBreakComplete() {
        #expect(HapticEvent.forTransition(from: .shortBreak, to: .focus) == .breakComplete)
        #expect(HapticEvent.forTransition(from: .longBreak, to: .focus) == .breakComplete)
    }

    @Test func endingALongBreakCompletesTheCycle() {
        #expect(HapticEvent.forTransition(from: .longBreak, to: .idle) == .cycleComplete)
    }

    @Test func captureAndUnchangedStatesStaySilent() {
        #expect(HapticEvent.forTransition(from: .focus, to: .focus) == nil)
        #expect(HapticEvent.forTransition(from: .focus, to: .capture) == nil)
        #expect(HapticEvent.forTransition(from: .capture, to: .focus) == nil)
    }

    @Test func cancellingAFocusSessionStaysSilent() {
        #expect(HapticEvent.forTransition(from: .focus, to: .idle) == nil)
        #expect(HapticEvent.forTransition(from: .shortBreak, to: .idle) == nil)
    }
}
