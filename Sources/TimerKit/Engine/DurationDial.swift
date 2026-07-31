// DurationDial.swift
//
// Pure duration-snapping logic behind the watchOS Digital Crown. Lives in
// TimerKit rather than the watch target so it stays unit-testable from
// the command line.

import Foundation

public enum DurationDial {
    /// Shortest selectable session.
    public static let minimum: TimeInterval = 5 * 60

    /// Longest selectable session.
    public static let maximum: TimeInterval = 120 * 60

    /// Crown detent size.
    public static let step: TimeInterval = 5 * 60

    /// Clamp into range, then snap to the nearest 5-minute detent.
    public static func snap(_ raw: TimeInterval) -> TimeInterval {
        let clamped = min(maximum, max(minimum, raw))
        let detents = (clamped / step).rounded()
        return min(maximum, max(minimum, detents * step))
    }

    /// Crown bindings work in minutes; convert a duration for display.
    public static func minutes(from duration: TimeInterval) -> Double {
        (snap(duration) / 60).rounded()
    }

    /// Convert a crown value back into a snapped duration.
    public static func duration(fromMinutes minutes: Double) -> TimeInterval {
        snap(minutes * 60)
    }
}
