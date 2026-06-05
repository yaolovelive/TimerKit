// DeviceIdentity.swift
//
// Stable, persistent identifier for the current device. Used to stamp
// TimerSession.initiatedByDeviceID so we can attribute sync events
// to the originating device and detect echoes in conflict resolution.

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public enum DeviceIdentity {
    private static let key = "tact.deviceID"

    public static var current: String {
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: key)
        return new
    }

    public static var platform: String {
        #if os(macOS)
        return "macOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #else
        return "unknown"
        #endif
    }
}
