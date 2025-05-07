import XCTest
@testable import ClipboardHistory

class LaunchAtLoginManagerTests: XCTestCase {
    var testDir: URL!

    override func setUpWithError() throws {
        // Setup a temporary LaunchAgents directory
        testDir = FileManager.default.temporaryDirectory.appendingPathComponent("launchAgentsTest", isDirectory: true)
        try? FileManager.default.removeItem(at: testDir)
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
        // Point manager to use the temp directory
        #if DEBUG
        LaunchAtLoginManager.testLaunchAgentsDirectory = testDir
        #endif
    }

    override func tearDownWithError() throws {
        // Clean up temp directory
        try? FileManager.default.removeItem(at: testDir)
        #if DEBUG
        LaunchAtLoginManager.testLaunchAgentsDirectory = nil
        #endif
    }

    func testIsEnabledDefaultFalse() throws {
        XCTAssertFalse(LaunchAtLoginManager.isEnabled())
    }

    func testSetEnabledTrueCreatesPlist() throws {
        LaunchAtLoginManager.setEnabled(true)
        XCTAssertTrue(FileManager.default.fileExists(atPath: LaunchAtLoginManager.plistURL.path))
    }

    func testSetEnabledFalseRemovesPlist() throws {
        // Enable then disable
        LaunchAtLoginManager.setEnabled(true)
        XCTAssertTrue(LaunchAtLoginManager.isEnabled())
        LaunchAtLoginManager.setEnabled(false)
        XCTAssertFalse(LaunchAtLoginManager.isEnabled())
    }
}
