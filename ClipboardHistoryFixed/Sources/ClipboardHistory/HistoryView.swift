import SwiftUI
import CoreData
import Combine
import AppKit
import Carbon.HIToolbox

struct ClipboardEntryViewModel: Identifiable {
    let object: NSManagedObject
    var id: NSManagedObjectID { object.objectID }
    var content: String { object.value(forKey: "content") as! String }
    var timestamp: Date { object.value(forKey: "timestamp") as! Date }
    var pinned: Bool { object.value(forKey: "pinned") as! Bool }
}

class HistoryViewModel: ObservableObject {
    @Published var entries: [ClipboardEntryViewModel] = []

    func refresh() {
        do {
            let objects = try PersistenceController.shared.fetchEntries()
            entries = objects.map { ClipboardEntryViewModel(object: $0) }
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func delete(_ entry: ClipboardEntryViewModel) {
        do {
            try PersistenceController.shared.deleteEntry(entry.object)
            refresh()
        } catch {
            print("Delete error: \(error)")
        }
    }

    func togglePin(_ entry: ClipboardEntryViewModel) {
        let obj = entry.object
        obj.setValue(!entry.pinned, forKey: "pinned")
        do {
            try obj.managedObjectContext?.save()
            refresh()
        } catch {
            print("Toggle pin error: \(error)")
        }
    }
}

struct HistoryView: View {
    @StateObject private var vm = HistoryViewModel()
    @State private var searchText: String = ""
    @State private var selectedIndex: Int = -1
    @State private var eventMonitor: Any? = nil

    private var filteredEntries: [ClipboardEntryViewModel] {
        vm.entries.filter { searchText.isEmpty || $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    /// Copy to clipboard, close popover, and auto-paste into front app
    private func performPaste(_ entry: ClipboardEntryViewModel) {
        // Update timestamp to bring this entry to top and avoid duplicate add
        if let context = entry.object.managedObjectContext {
            entry.object.setValue(Date(), forKey: "timestamp")
            try? context.save()
            vm.refresh()
        }
        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(entry.content, forType: .string)
        // Delay to restore focus, close popover, and paste
        if let delegate = NSApp.delegate as? AppDelegate {
            let previous = delegate.previousActiveApp
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Reactivate last active app
                previous?.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
                // Close popover
                delegate.togglePopover(nil)
                // Simulate Cmd+V
                let src = CGEventSource(stateID: .hidSystemState)
                let keyDown = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
                keyDown?.flags = .maskCommand
                let keyUp = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
                keyUp?.flags = .maskCommand
                keyDown?.post(tap: .cghidEventTap)
                keyUp?.post(tap: .cghidEventTap)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Clipboard History")
                    .font(.headline)
                Spacer()
                Button(action: { vm.refresh() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
            }
            .padding([.top, .horizontal])
            // Search field
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            List {
                ForEach(filteredEntries.indices, id: \.self) { idx in
                    let entry = filteredEntries[idx]
                    HStack {
                        Text(entry.content)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.timestamp, style: .time)
                            .font(.caption)
                    }
                    .background(idx == selectedIndex ? Color.accentColor.opacity(0.2) : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedIndex = idx
                        performPaste(entry)
                    }
                    .contextMenu {
                        Button(action: { vm.togglePin(entry) }) {
                            Text(entry.pinned ? "Unpin" : "Pin")
                            Image(systemName: entry.pinned ? "pin.slash" : "pin")
                        }
                        Button(role: .destructive) { vm.delete(entry) } label: {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .onAppear { vm.refresh() }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ClipboardHistoryPopoverWillShow"))) { _ in
            vm.refresh()
            selectedIndex = filteredEntries.isEmpty ? -1 : 0
        }
        .onAppear {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                switch event.keyCode {
                case UInt16(kVK_DownArrow):
                    if !filteredEntries.isEmpty {
                        selectedIndex = min(filteredEntries.count - 1, max(0, selectedIndex + 1))
                    }
                    return nil
                case UInt16(kVK_UpArrow):
                    if !filteredEntries.isEmpty {
                        selectedIndex = max(0, min(filteredEntries.count - 1, selectedIndex - 1))
                    }
                    return nil
                case UInt16(kVK_Return), UInt16(kVK_ANSI_KeypadEnter):
                    if selectedIndex >= 0 && selectedIndex < filteredEntries.count {
                        performPaste(filteredEntries[selectedIndex])
                    }
                    return nil
                default:
                    return event
                }
            }
        }
        .onDisappear {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}
