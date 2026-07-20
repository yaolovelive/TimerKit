// TimerEngineTests.swift

import Foundation
import Testing
@testable import TimerKit

@MainActor
struct TimerEngineTests {
    @Test func startsRunningSession() {
        let engine = TimerEngine()
        let session = TimerSession(
            duration: 60,
            initiatedByDeviceID: "test-device"
        )
        engine.start(session)

        #expect(engine.activeSession?.id == session.id)
        #expect(engine.activeSession?.state == .running)
    }

    @Test func startRefreshesLastTickTime() {
        let engine = TimerEngine()
        let previousTick = engine.lastTickAt
        Thread.sleep(forTimeInterval: 0.01)

        engine.start(TimerSession(
            duration: 60,
            initiatedByDeviceID: "test-device"
        ))

        #expect(engine.lastTickAt > previousTick)
    }

    @Test func pauseAddsPauseRecord() {
        let engine = TimerEngine()
        let session = TimerSession(
            duration: 60,
            initiatedByDeviceID: "test-device"
        )
        engine.start(session)
        engine.pause()

        #expect(engine.activeSession?.state == .paused)
        #expect(engine.activeSession?.pauseHistory.count == 1)
        #expect(engine.activeSession?.pauseHistory.first?.resumedAt == nil)
    }

    @Test func resumeClosesOpenPauseRecord() {
        let engine = TimerEngine()
        let session = TimerSession(
            duration: 60,
            initiatedByDeviceID: "test-device"
        )
        engine.start(session)
        engine.pause()
        engine.resume()

        #expect(engine.activeSession?.state == .running)
        #expect(engine.activeSession?.pauseHistory.first?.resumedAt != nil)
    }

    @Test func resumeRefreshesLastTickTime() {
        let engine = TimerEngine()
        let session = TimerSession(
            duration: 60,
            initiatedByDeviceID: "test-device"
        )
        engine.start(session)
        engine.pause()
        let previousTick = engine.lastTickAt
        Thread.sleep(forTimeInterval: 0.01)

        engine.resume()

        #expect(engine.lastTickAt > previousTick)
    }

    @Test func elapsedExcludesPauseDuration() {
        let started = Date().addingTimeInterval(-100)
        let pauseStart = started.addingTimeInterval(40)
        let pauseEnd = started.addingTimeInterval(60)
        let session = TimerSession(
            startedAt: started,
            duration: 300,
            pauseHistory: [PauseRecord(pausedAt: pauseStart, resumedAt: pauseEnd)],
            initiatedByDeviceID: "test"
        )
        // 100 seconds wall clock, 20 seconds paused → 80 elapsed.
        let elapsed = session.elapsed(at: started.addingTimeInterval(100))
        #expect(abs(elapsed - 80) < 0.5)
    }
}
