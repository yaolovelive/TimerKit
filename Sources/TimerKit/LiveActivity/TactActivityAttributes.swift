import Foundation

#if os(iOS) && canImport(ActivityKit)
import ActivityKit

public struct TactActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var stateName: String
        public var endDate: Date
        public var isPaused: Bool
        public var contextTitle: String

        public init(
            stateName: String,
            endDate: Date,
            isPaused: Bool,
            contextTitle: String
        ) {
            self.stateName = stateName
            self.endDate = endDate
            self.isPaused = isPaused
            self.contextTitle = contextTitle
        }
    }

    public var sessionID: UUID

    public init(sessionID: UUID) {
        self.sessionID = sessionID
    }
}
#endif
