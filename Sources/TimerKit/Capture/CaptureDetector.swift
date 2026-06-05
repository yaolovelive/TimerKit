// CaptureDetector.swift
//
// Runs on every keystroke in the quick capture panel (debounced).
// Detects URLs, dates, contacts, todos, hashtags, and questions using
// NSDataDetector and lightweight regex. Returns a list of Detection
// chips to render below the input.
//
// All detection is local — no network, no ML inference cost.

import Foundation

public struct Detection: Sendable, Hashable {
    public enum Kind: Sendable, Hashable {
        case url(URL)
        case date(Date)
        case phone(String)
        case email(String)
        case todo
        case tag(name: String)
        case question
    }

    public let kind: Kind
    public let range: Range<String.Index>

    public init(kind: Kind, range: Range<String.Index>) {
        self.kind = kind
        self.range = range
    }
}

public struct CaptureDetector: Sendable {
    private let dataDetector: NSDataDetector

    public init() {
        let types: NSTextCheckingResult.CheckingType = [.link, .date, .phoneNumber]
        // swiftlint:disable:next force_try
        self.dataDetector = try! NSDataDetector(types: types.rawValue)
    }

    public func detect(_ text: String) -> [Detection] {
        guard !text.isEmpty else { return [] }
        var out: [Detection] = []

        let nsRange = NSRange(text.startIndex..., in: text)
        let matches = dataDetector.matches(in: text, range: nsRange)

        for match in matches {
            guard let range = Range(match.range, in: text) else { continue }
            switch match.resultType {
            case .link:
                if let url = match.url { out.append(.init(kind: .url(url), range: range)) }
            case .date:
                if let date = match.date { out.append(.init(kind: .date(date), range: range)) }
            case .phoneNumber:
                if let phone = match.phoneNumber {
                    out.append(.init(kind: .phone(phone), range: range))
                }
            default:
                break
            }
        }

        // Email — NSDataDetector doesn't catch these on all OS versions,
        // so we add a simple regex check.
        if let emailRange = text.firstMatch(of: emailRegex) {
            let value = String(text[emailRange.range])
            out.append(.init(kind: .email(value), range: emailRange.range))
        }

        // Todo prefix
        let lowered = text.lowercased()
        if lowered.hasPrefix("- ") || lowered.hasPrefix("todo:") || lowered.hasPrefix("* ") {
            out.append(.init(kind: .todo, range: text.startIndex..<text.index(after: text.startIndex)))
        }

        // Hashtag
        if let match = text.firstMatch(of: hashtagRegex) {
            let name = String(match.output.1)
            out.append(.init(kind: .tag(name: name), range: match.range))
        }

        // Question
        if text.hasSuffix("?") {
            let last = text.index(before: text.endIndex)
            out.append(.init(kind: .question, range: last..<text.endIndex))
        }

        return out
    }

    private var emailRegex: Regex<Substring> {
        // swiftlint:disable:next force_try
        try! Regex(#"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#)
    }

    private var hashtagRegex: Regex<(Substring, Substring)> {
        // swiftlint:disable:next force_try
        try! Regex(#"#(\w+)"#)
    }
}

// MARK: - Derive MemoType from detections

public extension Array where Element == Detection {
    /// The primary MemoType for routing this capture to inbox subgroups.
    var primaryMemoType: MemoType {
        if contains(where: { if case .date = $0.kind { return true } else { return false } }) {
            return .reminder
        }
        if contains(where: { if case .todo = $0.kind { return true } else { return false } }) {
            return .todo
        }
        if contains(where: { if case .url = $0.kind { return true } else { return false } }) {
            return .url
        }
        if contains(where: {
            switch $0.kind {
            case .phone, .email: return true
            default: return false
            }
        }) {
            return .contact
        }
        if contains(where: { if case .question = $0.kind { return true } else { return false } }) {
            return .question
        }
        return .plain
    }
}
