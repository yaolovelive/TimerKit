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
