// SoundLibrary.swift
//
// Catalog of every sound asset shipping with the app. The actual AAC
// files live in Resources/Sounds and are bundled with each app target.
// See docs/05-sound.md for the design rationale and the 1.2-second rule.

import Foundation

public enum EndSound: String, CaseIterable, Sendable, Codable {
    case chime    // default, free tier
    case bell     // free tier
    case silent   // free tier — no audio, watch haptic only

    public var displayName: String {
        switch self {
        case .chime: return "Chime"
        case .bell: return "Bell"
        case .silent: return "Silent"
        }
    }

    /// Asset filename without extension. Silent has no file.
    public var assetName: String? {
        switch self {
        case .chime: return "end-chime"
        case .bell: return "end-bell"
        case .silent: return nil
        }
    }

    /// Hard limit per the 1.2-second rule.
    public var maxAllowedDuration: TimeInterval { 1.2 }
}

public enum WhiteNoise: String, CaseIterable, Sendable, Codable {
    // Nature
    case lightRain
    case heavyRain
    case wind
    case ocean
    case forestMorning

    // Spaces
    case coffeeShop
    case libraryHum
    case trainCabin
    case nightCrickets

    // Tonal
    case brownNoise
    case brownLowRumble
    case pinkNoise
    case tapeHissVinyl

    // Meditative
    case singingBowl
    case distantChimes

    public var displayName: String {
        switch self {
        case .lightRain: return "Light rain"
        case .heavyRain: return "Heavy rain"
        case .wind: return "Wind through trees"
        case .ocean: return "Ocean waves"
        case .forestMorning: return "Forest morning"
        case .coffeeShop: return "Coffee shop"
        case .libraryHum: return "Library hum"
        case .trainCabin: return "Train cabin"
        case .nightCrickets: return "Night crickets"
        case .brownNoise: return "Brown noise"
        case .brownLowRumble: return "Brown + low rumble"
        case .pinkNoise: return "Pink noise"
        case .tapeHissVinyl: return "Tape hiss & vinyl"
        case .singingBowl: return "Singing bowl"
        case .distantChimes: return "Distant chimes"
        }
    }

    public var assetName: String { "wn-\(rawValue)" }

    /// Free tier gets none. Premium unlocks all.
    public var requiresPro: Bool { true }
}

public enum SoundLibrary {
    public static let freeTierEndSounds: [EndSound] = [.chime, .bell, .silent]
    public static let proTierWhiteNoises: [WhiteNoise] = WhiteNoise.allCases
}
