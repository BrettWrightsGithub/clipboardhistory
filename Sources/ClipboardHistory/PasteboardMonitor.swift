import Foundation
import AppKit

/// Protocol to abstract NSPasteboard for testability
protocol PasteboardProviding {
    var changeCount: Int { get }
    func string(forType type: NSPasteboard.PasteboardType) -> String?
}

/// Default provider wrapping NSPasteboard.general
struct DefaultPasteboardProvider: PasteboardProviding {
    private let pasteboard = NSPasteboard.general
    var changeCount: Int { pasteboard.changeCount }
    func string(forType type: NSPasteboard.PasteboardType) -> String? {
        return pasteboard.string(forType: type)
    }
}

/// Monitors the pasteboard for new string entries.
class PasteboardMonitor {
    private let provider: PasteboardProviding
    private var lastChangeCount: Int
    private var timer: Timer?

    /// Called when a new string is copied to the pasteboard.
    var onNewString: (String) -> Void = { _ in }

    init(provider: PasteboardProviding = DefaultPasteboardProvider()) {
        self.provider = provider
        self.lastChangeCount = provider.changeCount
    }

    /// Start polling the pasteboard at the given interval (seconds).
    func startPolling(interval: TimeInterval = 1.0) {
        stopPolling()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.pollOnce()
        }
    }

    /// Stop polling.
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    /// Check for new pasteboard content once.
    func pollOnce() {
        let currentCount = provider.changeCount
        if currentCount != lastChangeCount {
            lastChangeCount = currentCount
            if let newString = provider.string(forType: .string) {
                onNewString(newString)
            }
        }
    }
}
