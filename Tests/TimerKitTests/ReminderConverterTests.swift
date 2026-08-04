import Foundation
import Testing
@testable import TimerKit

struct ReminderConverterTests {
    @Test func removesDetectedDatePhraseFromReminderTitle() throws {
        let content = "買菜 明天下午3點"
        let dateRange = try #require(content.range(of: "明天下午3點"))
        let dueDate = Date(timeIntervalSince1970: 1_754_000_000)
        let detection = Detection(kind: .date(dueDate), range: dateRange)

        let draft = try ReminderConverter.draft(content: content, detections: [detection])

        #expect(draft.title == "買菜")
        #expect(draft.dueDate == dueDate)
    }

    @Test func trimsPunctuationAndWhitespaceAroundDatePhrase() throws {
        let content = "提醒我：寄信，明天"
        let dateRange = try #require(content.range(of: "明天"))
        let dueDate = Date(timeIntervalSince1970: 1_754_000_000)
        let detection = Detection(kind: .date(dueDate), range: dateRange)

        let draft = try ReminderConverter.draft(content: content, detections: [detection])

        #expect(draft.title == "提醒我：寄信")
    }

    @Test func rejectsMemoWithoutDateDetection() {
        #expect(throws: ReminderConversionError.noDueDate) {
            try ReminderConverter.draft(content: "Buy milk", detections: [])
        }
    }
}
