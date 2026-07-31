import Foundation

#if os(iOS)

public enum TactCommandKind: String, Codable {
    case togglePrimary
    case cancel
}

public struct TactPendingCommand: Codable {
    public let kind: TactCommandKind
    public let issuedAt: Date

    public init(kind: TactCommandKind, issuedAt: Date = Date()) {
        self.kind = kind
        self.issuedAt = issuedAt
    }
}

#endif
