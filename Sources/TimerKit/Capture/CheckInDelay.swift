import Foundation

public enum CheckInDelay: String, CaseIterable, Sendable {
    case thirtyMinutes
    case twoHours
    case tomorrow

    public var label: String {
        switch self {
        case .thirtyMinutes: "30 分钟"
        case .twoHours: "2 小时"
        case .tomorrow: "明天"
        }
    }

    public func fireDate(from now: Date = Date(), calendar: Calendar = .current) -> Date {
        switch self {
        case .thirtyMinutes:
            now.addingTimeInterval(30 * 60)
        case .twoHours:
            now.addingTimeInterval(2 * 60 * 60)
        case .tomorrow:
            calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(24 * 60 * 60)
        }
    }
}
