//
//  ClipboardHistoryUITestsLaunchTests.swift
//  ClipboardHistoryUITests
//
//  Created by Brett Wright on 5/3/25.
//

import XCTest

final class ClipboardHistoryUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        try XCTSkip("Skipping UI launch test; UI verification is manual.")
    }
}
