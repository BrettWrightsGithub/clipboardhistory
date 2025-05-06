//
//  ClipboardHistoryTests.swift
//  ClipboardHistoryTests
//
//  Created by Brett Wright on 5/3/25.
//

import XCTest
import AppKit
@testable import ClipboardHistory

final class PasteboardMonitorTests: XCTestCase {
    class FakeProvider: PasteboardProviding {
        var changeCountValue: Int
        var stringValue: String?
        init(changeCount: Int, string: String?) {
            self.changeCountValue = changeCount
            self.stringValue = string
        }
        var changeCount: Int { changeCountValue }
        func string(forType type: NSPasteboard.PasteboardType) -> String? {
            return stringValue
        }
    }

    func testPollOnce_NoChange_DoesNotCallOnNew() {
        let provider = FakeProvider(changeCount: 1, string: "Initial")
        let monitor = PasteboardMonitor(provider: provider)
        var received: String?
        monitor.onNewString = { str in received = str }
        monitor.pollOnce()
        XCTAssertNil(received, "onNewString should not be called when changeCount is unchanged")
    }

    func testPollOnce_Change_CallsOnNewString() {
        let provider = FakeProvider(changeCount: 1, string: "Hello World")
        let monitor = PasteboardMonitor(provider: provider)
        var received: String?
        monitor.onNewString = { str in received = str }
        // simulate pasteboard change
        provider.changeCountValue += 1
        monitor.pollOnce()
        XCTAssertEqual(received, "Hello World", "onNewString should be called with new clipboard string")
    }
}
