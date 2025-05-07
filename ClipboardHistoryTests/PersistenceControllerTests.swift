import XCTest
import CoreData
@testable import ClipboardHistory

final class PersistenceControllerTests: XCTestCase {
    func testAddAndFetchEntry() throws {
        let controller = PersistenceController(inMemory: true)
        controller.addEntry(content: "Hello", type: "string")
        let entries = try controller.fetchEntries()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.value(forKey: "content") as? String, "Hello")
        XCTAssertEqual(entries.first?.value(forKey: "type") as? String, "string")
    }

    func testFetchLimit() throws {
        let controller = PersistenceController(inMemory: true)
        controller.addEntry(content: "One", type: "string")
        controller.addEntry(content: "Two", type: "string")
        let entries = try controller.fetchEntries(limit: 1)
        XCTAssertEqual(entries.count, 1)
    }

    func testDeleteEntry() throws {
        let controller = PersistenceController(inMemory: true)
        controller.addEntry(content: "DeleteMe", type: "string")
        var entries = try controller.fetchEntries()
        XCTAssertEqual(entries.count, 1)
        if let entry = entries.first {
            try controller.deleteEntry(entry)
        }
        entries = try controller.fetchEntries()
        XCTAssertEqual(entries.count, 0)
    }

    func testEntriesSortedByTimestamp() throws {
        let controller = PersistenceController(inMemory: true)
        controller.addEntry(content: "First", type: "text")
        Thread.sleep(forTimeInterval: 0.01)
        controller.addEntry(content: "Second", type: "text")
        let entries = try controller.fetchEntries()
        XCTAssertEqual(entries[0].value(forKey: "content") as? String, "Second")
        XCTAssertEqual(entries[1].value(forKey: "content") as? String, "First")
    }

    func testPurgeExcessEntries() throws {
        let controller = PersistenceController(inMemory: true)
        for i in 1...5 {
            controller.addEntry(content: "Item\(i)", type: "string")
        }
        try controller.purgeExcessEntries(keeping: 3)
        let entries = try controller.fetchEntries()
        XCTAssertEqual(entries.count, 3)
        let contents = entries.map { $0.value(forKey: "content") as? String }
        XCTAssertEqual(contents, ["Item5", "Item4", "Item3"] )
    }

    func testAddEntryEnforcesMaxItems() throws {
        UserDefaults.standard.set(2, forKey: "maxItems")
        let controller = PersistenceController(inMemory: true)
        controller.addEntry(content: "One", type: "string")
        controller.addEntry(content: "Two", type: "string")
        controller.addEntry(content: "Three", type: "string")
        let entries = try controller.fetchEntries()
        XCTAssertEqual(entries.count, 2)
        let contents = entries.map { $0.value(forKey: "content") as? String }
        XCTAssertEqual(contents, ["Three", "Two"] )
        UserDefaults.standard.removeObject(forKey: "maxItems")
    }
}
