// WeeklyReportGenerator.swift
//
// Orchestrates the weekly report generation. On Apple Intelligence
// devices, runs LanguageModelSession with a structured @Generable
// output. Otherwise, returns a rule-based WeeklyReportFallback.

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Per-week aggregate the generator receives as input. Pre-built by
/// the caller from SwiftData queries — keeps the generator pure.
public struct WeekAggregate: Sendable {
    public let weekOf: Date
    public let totalFocusMinutes: Int
    public let completedPomodoros: Int
    public let pollutedPomodoros: Int
    public let memoCount: Int
    public let memoCountByType: [MemoType: Int]
    public let sessionsByDayOfWeek: [Int: Int]    // 1...7 (Sun=1) -> count
    public let sessionsByHourBucket: [Int: Int]   // 0...23 -> count
    public let topTagsByMinutes: [(name: String, minutes: Int)]
    public let completionRateByTag: [(name: String, rate: Double)]

    /// Delta vs previous 7-day window.
    public let focusMinutesDelta: Int
    public let pomodorosDelta: Int

    public init(
        weekOf: Date,
        totalFocusMinutes: Int,
        completedPomodoros: Int,
        pollutedPomodoros: Int,
        memoCount: Int,
        memoCountByType: [MemoType: Int],
        sessionsByDayOfWeek: [Int: Int],
        sessionsByHourBucket: [Int: Int],
        topTagsByMinutes: [(name: String, minutes: Int)],
        completionRateByTag: [(name: String, rate: Double)],
        focusMinutesDelta: Int,
        pomodorosDelta: Int
    ) {
        self.weekOf = weekOf
        self.totalFocusMinutes = totalFocusMinutes
        self.completedPomodoros = completedPomodoros
        self.pollutedPomodoros = pollutedPomodoros
        self.memoCount = memoCount
        self.memoCountByType = memoCountByType
        self.sessionsByDayOfWeek = sessionsByDayOfWeek
        self.sessionsByHourBucket = sessionsByHourBucket
        self.topTagsByMinutes = topTagsByMinutes
        self.completionRateByTag = completionRateByTag
        self.focusMinutesDelta = focusMinutesDelta
        self.pomodorosDelta = pomodorosDelta
    }
}

public enum WeeklyReportResult: Sendable {
    case ai(WeeklyReport)
    case fallback(WeeklyReportFallback)
    case insufficientData
}

public struct WeeklyReportGenerator: Sendable {
    public init() {}

    public func generate(from aggregate: WeekAggregate) async throws -> WeeklyReportResult {
        guard aggregate.completedPomodoros >= 3 else {
            return .insufficientData
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *), await isAppleIntelligenceAvailable() {
            let report = try await generateAIReport(from: aggregate)
            return .ai(report)
        }
        #endif

        return .fallback(generateFallback(from: aggregate))
    }

    // MARK: - AI path

    #if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    private func generateAIReport(from aggregate: WeekAggregate) async throws -> WeeklyReport {
        let session = LanguageModelSession(instructions: Self.systemPrompt)
        let userPayload = encode(aggregate)
        let response = try await session.respond(
            to: userPayload,
            generating: GeneratedWeeklyReport.self
        )
        return response.content.report
    }

    @available(iOS 26.0, macOS 26.0, *)
    private func isAppleIntelligenceAvailable() async -> Bool {
        // TODO: probe SystemLanguageModel.default.availability.
        true
    }

    private func encode(_ aggregate: WeekAggregate) -> String {
        // TODO: serialize to compact JSON. Don't include raw memo bodies —
        // only counts and metadata. See docs/04-ai-reports.md (privacy).
        "TODO: structured JSON of weekly aggregate"
    }

    private static let systemPrompt = """
        You are writing a brief weekly reflection for a focus tracking app user.
        Style: calm, observational, specific. Never generic praise.
        Always reference the user's actual tag names and time windows.
        If patterns are weak or absent, say so honestly — do not invent.
        Keep each section to one or two sentences.
        """
    #endif

    // MARK: - Fallback path

    private func generateFallback(from aggregate: WeekAggregate) -> WeeklyReportFallback {
        let bestDayIndex = aggregate.sessionsByDayOfWeek
            .max(by: { $0.value < $1.value })?.key ?? 1
        let bestDayName = ["Sunday", "Monday", "Tuesday", "Wednesday",
                           "Thursday", "Friday", "Saturday"][bestDayIndex - 1]

        let topTag = aggregate.topTagsByMinutes.first?.name

        let headline = aggregate.focusMinutesDelta > 0
            ? "A strong week — \(aggregate.focusMinutesDelta) more focus minutes than last."
            : "A steady week."

        return WeeklyReportFallback(
            headline: headline,
            focusMinutes: aggregate.totalFocusMinutes,
            completedPomodoros: aggregate.completedPomodoros,
            bestDay: bestDayName,
            topTagName: topTag,
            streakDays: 0 // TODO: compute from DailyStats
        )
    }
}
