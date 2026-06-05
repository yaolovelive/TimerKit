import SwiftData
import Testing
@testable import TimerKit

@Suite
struct CloudKitContainerTests {
    @Test
    func createsInMemoryLocalContainer() throws {
        let container = try CloudKitContainer.makeLocal(inMemoryOnly: true)

        #expect(container.schema.entities.count == CloudKitContainer.schema.entities.count)
    }

    @Test
    func createsCloudKitConfiguredInMemoryContainer() throws {
        let container = try CloudKitContainer.make(inMemoryOnly: true)

        #expect(container.schema.entities.count == CloudKitContainer.schema.entities.count)
    }
}
