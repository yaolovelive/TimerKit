// CloudKitContainer.swift
//
// SwiftData's CloudKit-backed ModelContainer. Defines the SwiftData
// schema and binds it to the iCloud private database for the user.
//
// IMPORTANT: any change to @Model schema after launch is constrained
// by CloudKit's "additive only" rule. New optional fields are safe;
// renaming/removing/changing types breaks existing users. Plan
// thoroughly before changing.
//
// See docs/02-architecture.md.

import Foundation
import SwiftData

public enum CloudKitContainer {
    /// Must match the iCloud container entitlement in each app target.
    public static let identifier = "iCloud.com.a1itx.tact"

    public static var schema: Schema {
        Schema([
            TimerSession.self,
            PomodoroSession.self,
            Memo.self,
            Tag.self,
            DailyStats.self,
        ])
    }

    public static func make(inMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Self.schema
        let configuration: ModelConfiguration = if inMemoryOnly {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .private(identifier)
            )
        }

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    public static func makeForAppLaunch() throws -> ModelContainer {
        #if DEBUG
        if ProcessInfo.processInfo.environment["TACT_USE_CLOUDKIT"] == "1" {
            return try make()
        }
        return try makeLocal(inMemoryOnly: true)
        #else
        return try make()
        #endif
    }

    public static func makeLocal(inMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Self.schema
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemoryOnly
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    public static func describe(_ error: Error) -> String {
        let nsError = error as NSError
        var lines = [
            "\(type(of: error)): \(error)",
            "domain=\(nsError.domain) code=\(nsError.code)",
        ]

        for (key, value) in nsError.userInfo.sorted(by: { $0.key < $1.key }) {
            lines.append("\(key): \(value)")
        }

        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            lines.append("underlying: \(describe(underlying))")
        }

        return lines.joined(separator: "\n")
    }
}
