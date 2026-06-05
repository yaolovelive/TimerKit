// swift-tools-version: 6.0
// Package.swift — TimerKit
//
// Shared business logic library used by all three app targets:
// - Tact-macOS
// - Tact-iOS (also serves iPadOS)
// - Tact-watchOS
//
// See docs/02-architecture.md for the rationale of keeping all
// logic here and only platform-specific UI/system integration in
// the app targets.

import PackageDescription

let package = Package(
    name: "TimerKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
    ],
    products: [
        .library(name: "TimerKit", targets: ["TimerKit"]),
    ],
    targets: [
        .target(
            name: "TimerKit",
            path: "Sources/TimerKit"
        ),
        .testTarget(
            name: "TimerKitTests",
            dependencies: ["TimerKit"],
            path: "Tests/TimerKitTests"
        ),
    ]
)
