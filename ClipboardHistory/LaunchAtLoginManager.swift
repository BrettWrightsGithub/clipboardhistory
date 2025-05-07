import Foundation
import AppKit

/// Manages Launch at Login via LaunchAgents plist
struct LaunchAtLoginManager {
    #if DEBUG
    /// Override for unit tests
    static var testLaunchAgentsDirectory: URL?
    #endif
    /// Unique label for the LaunchAgent
    static let label = Bundle.main.bundleIdentifier ?? "com.clipboardhistory.app"
    /// Path to the user's LaunchAgents directory
    private static var launchAgentsDirectory: URL {
        #if DEBUG
        if let overrideDir = testLaunchAgentsDirectory {
            return overrideDir
        }
        #endif
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
    }
    /// Full URL of the plist file
    static var plistURL: URL {
        return launchAgentsDirectory.appendingPathComponent("\(label).plist")
    }

    /// Check if Launch at Login is enabled
    static func isEnabled() -> Bool {
        return FileManager.default.fileExists(atPath: plistURL.path)
    }

    /// Enable or disable Launch at Login
    static func setEnabled(_ enabled: Bool) {
        let fileManager = FileManager.default
        if enabled {
            // Prepare plist content
            guard let execURL = Bundle.main.executableURL else { return }
            let execPath = execURL.path
            let plistContent = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>\(label)</string>
                <key>ProgramArguments</key>
                <array>
                    <string>\(execPath)</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
            </dict>
            </plist>
            """
            // Ensure directory exists
            try? fileManager.createDirectory(at: launchAgentsDirectory, withIntermediateDirectories: true, attributes: nil)
            // Write the plist
            try? plistContent.write(to: plistURL, atomically: true, encoding: .utf8)
        } else {
            // Remove the plist to disable
            try? fileManager.removeItem(at: plistURL)
        }
    }
}
