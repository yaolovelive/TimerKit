// WeeklyReport.swift
//
// Structured output schema for the AI weekly report. We define the
// types as @Generable so Apple Foundation Models constrains the local
// LLM to produce a typed Swift struct rather than free-form text.
//
// This is the Pro-tier feature core. See docs/04-ai-reports.md.
//
// Availability note: FoundationModels is iOS 26+ / macOS 26+ / Apple
// Intelligence enabled devices only. Wrap usage in availability checks
// and provide a rule-based fallback for older or non-AI devices.

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

public struct WeeklyReport: Sendable {
    public let headline: String
    public let patterns: [Pattern]
    public let anomaly: Anomaly?
    public let reflectionQuestion: String
    public let suggestion: Suggestion

    public init(
        headline: String,
        patterns: [Pattern],
        anomaly: Anomaly?,
        reflectionQuestion: String,
        suggestion: Suggestion
    ) {
        self.headline = headline
        self.patterns = patterns
        self.anomaly = anomaly
        self.reflectionQuestion = reflectionQuestion
        self.suggestion = suggestion
    }
}

public struct Pattern: Sendable {
    public let observation: String
    public let evidence: String

    public init(observation: String, evidence: String) {
        self.observation = observation
        self.evidence = evidence
    }
}

public struct Anomaly: Sendable {
    public let what: String
    public let when: String

    public init(what: String, when: String) {
        self.what = what
        self.when = when
    }
}

public struct Suggestion: Sendable {
    public let action: String
    public let rationale: String

    public init(action: String, rationale: String) {
        self.action = action
        self.rationale = rationale
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GeneratedWeeklyReport: Sendable {
    @Guide(description: "One-sentence summary of the week's character. Specific, never generic praise.")
    let headline: String

    @Guide(description: "One or two patterns observed, each with concrete evidence from the data.")
    let patterns: [GeneratedPattern]

    @Guide(description: "An anomaly worth attention. Omit if the week was consistent.")
    let anomaly: GeneratedAnomaly?

    @Guide(description: "One open-ended reflective question for the user.")
    let reflectionQuestion: String

    @Guide(description: "One concrete actionable suggestion tied to the patterns.")
    let suggestion: GeneratedSuggestion

    var report: WeeklyReport {
        WeeklyReport(
            headline: headline,
            patterns: patterns.map(\.pattern),
            anomaly: anomaly?.anomaly,
            reflectionQuestion: reflectionQuestion,
            suggestion: suggestion.suggestion
        )
    }
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GeneratedPattern: Sendable {
    let observation: String
    let evidence: String

    var pattern: Pattern {
        Pattern(observation: observation, evidence: evidence)
    }
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GeneratedAnomaly: Sendable {
    let what: String
    let when: String

    var anomaly: Anomaly {
        Anomaly(what: what, when: when)
    }
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GeneratedSuggestion: Sendable {
    let action: String
    let rationale: String

    var suggestion: Suggestion {
        Suggestion(action: action, rationale: rationale)
    }
}
#endif

/// Rule-based fallback used on devices without Apple Intelligence, or
/// when the user opts out of AI features.
public struct WeeklyReportFallback: Sendable {
    public let headline: String
    public let focusMinutes: Int
    public let completedPomodoros: Int
    public let bestDay: String
    public let topTagName: String?
    public let streakDays: Int

    public init(
        headline: String,
        focusMinutes: Int,
        completedPomodoros: Int,
        bestDay: String,
        topTagName: String?,
        streakDays: Int
    ) {
        self.headline = headline
        self.focusMinutes = focusMinutes
        self.completedPomodoros = completedPomodoros
        self.bestDay = bestDay
        self.topTagName = topTagName
        self.streakDays = streakDays
    }
}
