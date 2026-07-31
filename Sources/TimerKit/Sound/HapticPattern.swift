// HapticPattern.swift
//
// The haptic "vocabulary" the user learns to recognize without looking
// at the screen. See docs/05-sound.md.

import Foundation

public enum HapticEvent: String, Sendable, Codable {
    case sessionStart       // single light tap
    case workComplete       // double tap ascending — "you earned a break"
    case breakComplete      // three quick taps — "back to it"
    case cycleComplete      // three quick taps + success cue
    case memoSyncedToCloud  // very light single click — "received"
}

#if os(watchOS)
import WatchKit

@MainActor
public final class HapticPlayer {
    public init() {}

    public func play(_ event: HapticEvent) {
        switch event {
        case .sessionStart:
            WKInterfaceDevice.current().play(.start)
        case .workComplete:
            WKInterfaceDevice.current().play(.success)
        case .breakComplete:
            WKInterfaceDevice.current().play(.notification)
        case .cycleComplete:
            playCycleCompletePattern()
        case .memoSyncedToCloud:
            WKInterfaceDevice.current().play(.click)
        }
    }

    private func playCycleCompletePattern() {
        Task { @MainActor in
            let device = WKInterfaceDevice.current()
            for _ in 0..<3 {
                device.play(.click)
                try? await Task.sleep(for: .milliseconds(120))
            }
            try? await Task.sleep(for: .milliseconds(150))
            device.play(.success)
        }
    }
}
#endif

#if canImport(SwiftUI)
extension HapticEvent {
    /// The haptic to play when the visual state changes. Returns nil when
    /// the transition should stay silent: nothing changed, the capture
    /// panel opened or closed (it carries its own confirmation), or the
    /// user cancelled a session (cancelling should not feel rewarded).
    public static func forTransition(from old: TactState, to new: TactState) -> HapticEvent? {
        guard old != new else { return nil }
        guard old != .capture, new != .capture else { return nil }

        switch (old, new) {
        case (_, .focus):
            return (old == .shortBreak || old == .longBreak) ? .breakComplete : .sessionStart
        case (.focus, .shortBreak), (.focus, .longBreak):
            return .workComplete
        case (.longBreak, .idle):
            return .cycleComplete
        default:
            return nil
        }
    }
}
#endif
