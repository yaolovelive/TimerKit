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

    /// Mid stop used for the active progress indicator and primary
    /// action affordances. Idle shares the focus accent so the start
    /// control reads as actionable before a session begins.
    public var accentColor: Color {
        switch self {
        case .idle, .focus: return Color(hex: 0x00B894)
        case .shortBreak:   return Color(hex: 0xFFB100)
        case .longBreak:    return Color(hex: 0x2ECC71)
        case .capture:      return Color(hex: 0x9B59B6)
        }
    }

    /// Muted companion to primaryTextColor for labels and captions.
    public var secondaryTextColor: Color {
        primaryTextColor.opacity(0.75)
    }

    /// Wallpaper-style gradient stops behind the main view on
    /// macOS/iOS. watchOS uses the flat backgroundColor instead.
    public var backgroundGradientColors: [Color] {
        switch self {
        case .idle:
            return [Color(hex: 0xFCF9F8), Color(hex: 0xF0EDED), Color(hex: 0xF2F2F7)]
        case .focus:
            return [Color(hex: 0xE6F4F1), Color(hex: 0xFFFFFF), Color(hex: 0x006B55).opacity(0.06)]
        case .shortBreak:
            return [Color(hex: 0xFFF8E6), Color(hex: 0xFFFFFF), Color(hex: 0xFFB100).opacity(0.09)]
        case .longBreak:
            return [Color(hex: 0xE8F5E9), Color(hex: 0xFFFFFF), Color(hex: 0x2ECC71).opacity(0.08)]
        case .capture:
            return [Color(hex: 0xF3E5F5), Color(hex: 0xE1BEE7)]
        }
    }

    /// Convenience gradient built from backgroundGradientColors.
    public var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: backgroundGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
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
