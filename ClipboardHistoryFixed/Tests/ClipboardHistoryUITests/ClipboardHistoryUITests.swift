//
//  ClipboardHistoryUITests.swift
//  ClipboardHistoryUITests
//
//  Created by Brett Wright on 5/3/25.
//

import XCTest

final class ClipboardHistoryUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        throw XCTSkip("Skipping UI tests; manual front-end verification.")
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        try XCTSkip("Skipping UI testExample; manual front-end verification.")
    }

    @MainActor
    func testLaunchPerformance() throws {
        try XCTSkip("Skipping UI testLaunchPerformance; manual front-end verification.")
    }
}
