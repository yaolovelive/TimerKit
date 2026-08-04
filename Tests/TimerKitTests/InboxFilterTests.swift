import Foundation
import Testing
@testable import TimerKit

struct InboxFilterTests {
    @Test func groupsByPrimaryMemoTypeOnly() {
        let reminder = Memo(content: "Buy milk?", detectedType: .reminder)
        let link = Memo(content: "https://example.com", detectedType: .url)
        let question = Memo(content: "What next?", detectedType: .question)

        let groups = InboxFilter.grouped([reminder, link, question])

        #expect(groups[.reminders]?.map(\.content) == ["Buy milk?"])
        #expect(groups[.links]?.map(\.content) == ["https://example.com"])
        #expect(groups[.questions]?.map(\.content) == ["What next?"])
    }

    @Test func excludesArchivedMemos() {
        let archived = Memo(content: "Old", detectedType: .question, archived: true)
        let active = Memo(content: "New", detectedType: .question)

        #expect(InboxFilter.filter([archived, active], group: .questions).map(\.content) == ["New"])
    }

    @Test func filtersByCapturedPomodoroID() {
        let pomodoroID = UUID()
        let matching = Memo(
            content: "Matching",
            capturedContext: CapturedContext(pomodoroID: pomodoroID)
        )
        let other = Memo(
            content: "Other",
            capturedContext: CapturedContext(pomodoroID: UUID())
        )

        #expect(InboxFilter.filter([other, matching], pomodoroID: pomodoroID).map(\.content) == ["Matching"])
    }

    @Test func sortsNewestFirst() {
        let old = Memo(createdAt: Date(timeIntervalSince1970: 1), content: "Old")
        let new = Memo(createdAt: Date(timeIntervalSince1970: 2), content: "New")

        #expect(InboxFilter.filter([old, new]).map(\.content) == ["New", "Old"])
    }
}
