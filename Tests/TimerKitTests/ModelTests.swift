import Foundation
import SwiftData
import Testing
@testable import TimerKit

@Suite
struct ModelTests {
    @Test
    func schemaContainsRoadmapEntities() {
        let entityNames = Set(CloudKitContainer.schema.entities.map(\.name))

        #expect(entityNames == [
            "TimerSession",
            "PomodoroSession",
            "Memo",
            "Tag",
            "DailyStats",
        ])
    }

    @Test
    func timerSessionRemainingNeverGoesNegative() {
        let startedAt = Date().addingTimeInterval(-120)
        let session = TimerSession(
            startedAt: startedAt,
            duration: 60,
            initiatedByDeviceID: "test-device"
        )

        #expect(session.remaining(at: Date()) == 0)
    }

    @Test
    func timerSessionFinishedReflectsTerminalStates() {
        let session = TimerSession(
            duration: 60,
            initiatedByDeviceID: "test-device"
        )

        #expect(!session.isFinished)

        session.state = .completed
        #expect(session.isFinished)

        session.state = .cancelled
        #expect(session.isFinished)
    }

    @Test
    func pomodoroSessionCountsCompletedAndInterruptedWorkRoundsOnly() {
        let pomodoro = PomodoroSession()
        pomodoro.rounds = [
            TimerSession(
                duration: 60,
                state: .completed,
                kind: .pomodoroWork,
                initiatedByDeviceID: "test-device",
                pomodoro: pomodoro
            ),
            TimerSession(
                duration: 60,
                state: .cancelled,
                kind: .pomodoroWork,
                initiatedByDeviceID: "test-device",
                pomodoro: pomodoro
            ),
            TimerSession(
                duration: 60,
                state: .completed,
                kind: .pomodoroShortBreak,
                initiatedByDeviceID: "test-device",
                pomodoro: pomodoro
            ),
        ]

        #expect(pomodoro.completedRoundCount == 1)
        #expect(pomodoro.interruptedRoundCount == 1)
    }

    @Test
    func memoPreservesCapturedContextSnapshot() {
        let context = CapturedContext(
            pomodoroID: UUID(),
            taskTitle: "Write spec",
            tagName: "Deep Work",
            timeIntoSession: 300
        )
        let memo = Memo(
            content: "Remember to check copy",
            detectedType: .todo,
            capturedContext: context
        )

        #expect(memo.detectedType == .todo)
        #expect(memo.capturedContext == context)
    }

    @Test
    func tagDefaultsAreStable() {
        let tag = Tag(name: "Writing", color: .teal)

        #expect(tag.name == "Writing")
        #expect(tag.color == .teal)
    }

    @Test
    func dailyStatsDefaultsToEmptyAggregates() {
        let day = Date(timeIntervalSince1970: 1_777_660_800)
        let stats = DailyStats(date: day)

        #expect(stats.date == day)
        #expect(stats.focusMinutes == 0)
        #expect(stats.completedPomodoros == 0)
        #expect(stats.pollutedPomodoros == 0)
        #expect(stats.memoCount == 0)
        #expect(stats.topTagID == nil)
    }
}
