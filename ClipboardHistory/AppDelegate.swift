import Cocoa
import SwiftUI
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    private var hotKeyRef: EventHotKeyRef?
    var previousActiveApp: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup popover with history view
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: HistoryView())

        // Setup status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard History")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Register global hotkey Option+V
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        var eventHandlerRef: EventHandlerRef?
        InstallEventHandler(GetEventDispatcherTarget(), hotKeyHandler, 1, &eventType, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &eventHandlerRef)
        let hotID = EventHotKeyID(signature: OSType(0x434C4950), id: 1)
        RegisterEventHotKey(UInt32(kVK_ANSI_V), UInt32(optionKey), hotID, GetEventDispatcherTarget(), 0, &hotKeyRef)
    }

    @objc func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            // Store the app that was frontmost before showing the popover
            previousActiveApp = NSWorkspace.shared.frontmostApplication
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Notify HistoryView to refresh when popover shows
            NotificationCenter.default.post(name: Notification.Name("ClipboardHistoryPopoverWillShow"), object: nil)
        }
    }
}

// Handler for global hotkey (Option+V)
private func hotKeyHandler(_ nextHandler: EventHandlerCallRef?, _ event: EventRef?, _ userData: UnsafeMutableRawPointer?) -> OSStatus {
    let delegate = Unmanaged<AppDelegate>.fromOpaque(userData!).takeUnretainedValue()
    delegate.togglePopover(nil)
    return noErr
}
