// DesignTokens.swift
//
// Single source of truth for typography, spacing, and radii. State
// colors are in StateColor.swift. See docs/01-design.md.

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public enum TactTokens {
    // MARK: - Spacing (4pt baseline)

    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }

    // MARK: - Corner radii (continuous)

    public enum Radius {
        public static let card: CGFloat = 12
        public static let panel: CGFloat = 16
        public static let pill: CGFloat = 999
    }

    // MARK: - Typography

    public enum Font {
        public static func timeNumeral(_ size: CGFloat = 64) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .rounded)
                .monospacedDigit()
        }

        public static let title: SwiftUI.Font = .system(size: 20, weight: .medium)
        public static let body: SwiftUI.Font = .system(size: 15, weight: .regular)
        public static let label: SwiftUI.Font = .system(size: 12, weight: .medium)
        public static let caption: SwiftUI.Font = .system(size: 11, weight: .regular)
    }

    // MARK: - Motion

    public enum Motion {
        public static let stateTransition: Animation = .smooth(duration: 0.4)
        public static let numberFlip: Animation = .easeOut(duration: 0.2)
        public static let panelAppear: Animation = .spring(response: 0.35, dampingFraction: 0.85)
    }
}
#endif
