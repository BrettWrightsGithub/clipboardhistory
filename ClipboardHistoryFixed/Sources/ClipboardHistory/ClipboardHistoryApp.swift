//
//  ClipboardHistoryApp.swift
//  ClipboardHistory
//
//  Created by Brett Wright on 5/3/25.
//

import SwiftUI
import AppKit

@main
struct ClipboardHistoryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Monitor the system clipboard at startup
    private let monitor = PasteboardMonitor()

    init() {
        monitor.onNewString = { newString in
            // Save entry to Core Data
            PersistenceController.shared.addEntry(content: newString, type: "string")
            print("📋 New clipboard entry: \(newString)")
        }
        monitor.startPolling()
        // Purge old entries on launch based on retention preference
        let days = UserDefaults.standard.integer(forKey: "retentionDays")
        do {
            try PersistenceController.shared.purgeOldEntries(olderThan: days)
        } catch {
            print("Error purging old entries: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Preferences panel
        Settings {
            PreferencesView()
        }
    }
}
