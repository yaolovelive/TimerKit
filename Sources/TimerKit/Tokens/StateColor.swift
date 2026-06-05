// StateColor.swift
//
// State is environment. The background color of the main view changes
// to communicate session state without needing a label. See
// docs/01-design.md (principle 2).

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public enum TactState: String, Sendable, CaseIterable {
    case idle
    case focus
    case shortBreak
    case longBreak
    case capture

    /// The tinted background hue used when this state is active.
    public var backgroundColor: Color {
        switch self {
        case .idle:        return Color(red: 0.95, green: 0.94, blue: 0.91)
        case .focus:       return Color(red: 0.88, green: 0.95, blue: 0.92)
        case .shortBreak:  return Color(red: 0.98, green: 0.93, blue: 0.84)
        case .longBreak:   return Color(red: 0.86, green: 0.95, blue: 0.85)
        case .capture:     return Color(red: 0.93, green: 0.91, blue: 0.97)
        }
    }

    /// Darkest stop from the same hue family, used for time numerals
    /// and primary text on the tinted background.
    public var primaryTextColor: Color {
        switch self {
        case .idle:        return Color(red: 0.18, green: 0.17, blue: 0.15)
        case .focus:       return Color(red: 0.06, green: 0.30, blue: 0.24)
        case .shortBreak:  return Color(red: 0.36, green: 0.22, blue: 0.04)
        case .longBreak:   return Color(red: 0.12, green: 0.36, blue: 0.18)
        case .capture:     return Color(red: 0.24, green: 0.21, blue: 0.50)
        }
    }

    /// Mid stop used for the active progress indicator.
    public var accentColor: Color {
        switch self {
        case .idle:        return Color(red: 0.53, green: 0.53, blue: 0.50)
        case .focus:       return Color(red: 0.11, green: 0.62, blue: 0.46)
        case .shortBreak:  return Color(red: 0.73, green: 0.46, blue: 0.09)
        case .longBreak:   return Color(red: 0.24, green: 0.62, blue: 0.31)
        case .capture:     return Color(red: 0.50, green: 0.47, blue: 0.87)
        }
    }
}

extension TactState {
    /// Derive the visual state from an active TimerSession.
    public static func from(session: TimerSession?) -> TactState {
        guard let session, !session.isFinished else { return .idle }
        switch session.kind {
        case .standalone, .pomodoroWork: return .focus
        case .pomodoroShortBreak:         return .shortBreak
        case .pomodoroLongBreak:          return .longBreak
        }
    }
}
#endif
