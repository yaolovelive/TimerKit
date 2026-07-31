// VoiceTranscript.swift
//
// Cleans text coming out of the watchOS system dictation panel before it
// becomes a Memo. Dictation joins spoken segments, which leaves doubled
// spaces and stray newlines behind.

import Foundation

public enum VoiceTranscript {
    /// Trim, collapse every whitespace run to a single space, and reject
    /// transcripts that carry no words. Returns nil when there is nothing
    /// worth saving.
    public static func normalize(_ raw: String) -> String? {
        let collapsed = raw
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
        return collapsed.isEmpty ? nil : collapsed
    }
}
