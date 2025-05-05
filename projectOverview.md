# Project Overview: macOS Clipboard History Application

## 1. Introduction

### 1.1 Purpose
Provide a lightweight, persistent clipboard history for macOS so users can recall and reuse past copied items.

### 1.2 Scope
- Monitor system clipboard in the background
- Store entries persistently on disk
- Expose a UI via the menu bar and a keyboard shortcut
- Support search, filtering, pinning, and clearing history
- Offer basic settings for retention and maximum items

## 2. Goals and Objectives
- Capture every new clipboard entry without impacting system performance
- Allow users to browse, search, and select previous entries
- Ensure data is stored securely and efficiently
- Deliver a seamless macOS-native experience using SwiftUI

## 3. Features
- Real-time clipboard monitoring (text, images)
- Persistent storage (SQLite via Core Data)
- Menu bar icon with dropdown history list
- Keyboard shortcut to open history window
- Global hotkey (Option+V) to summon history from any app
- Auto-paste selected entry into frontmost application
- Search and filter by keyword
- Pin/unpin favorite entries
- Clear individual entries or entire history
- Preferences panel (max items, retention period)
- Auto-launch at login via LaunchAgent

## 4. User Stories
- As a user, I want to retrieve the last 50 copied items so I never lose data.
- As a user, I want to search my clipboard history by keyword.
- As a user, I want to pin frequently used snippets to the top.
- As a user, I want to clear old entries older than 7 days automatically.

## 5. Technical Architecture

### 5.1 Platform & Language
- macOS 13+ using Swift 5 and SwiftUI in Xcode 15

### 5.2 Clipboard Monitoring
- Poll the NSPasteboard.generalPasteboard at configurable intervals
- Detect changes by comparing pasteboard changeCount

### 5.3 Data Storage
- Core Data with SQLite backend
- Entity: ClipboardEntry { id, content, type, timestamp, pinned }
- Migrations for future schema changes

### 5.4 UI/UX
- NSStatusBarItem hosting a SwiftUI view
- List view with dynamic search bar
- Context menu for pin, delete actions

### 5.5 Packaging & Distribution
- Code signing and notarization via Xcode
- Build universal .app and DMG installer
- Provide a README with installation instructions

## 6. Milestones & Timeline

| Milestone                  | Description                                                      | Duration |
|----------------------------|------------------------------------------------------------------|----------|
| M1: Dev Environment Setup  | Install Xcode, initialize Git repo, Hello World                  | 1 day    |
| M2: Clipboard Monitoring   | Implement pasteboard polling & logging                           | 2 days   |
| M3: Persistence Layer      | Setup Core Data model & CRUD operations                          | 2 days   |
| M4: History UI             | Menu bar icon & history list view                                | 3 days   |
| M5: Global Hotkey & Paste  | Integrate system-wide shortcut (Option+V) and auto-paste action  | 2 days   |
| M6: Search & Pinning       | Add search bar and pin/unpin functionality                        | 2 days   |
| M7: Preferences Panel      | Build settings for retention & item limits                       | 2 days   |
| M8: Packaging & Release    | Notarization, DMG creation, final QA                             | 2 days   |

## 7. Risks & Mitigations
- **Clipboard API changes**: use public NSPasteboard API only
- **Performance impact**: optimize polling interval to balance latency and CPU usage
- **Data growth**: enforce retention policy and max items setting

## 8. Deliverables
- Fully functional macOS app (.app bundle)
- Source code repository with clear commit history
- README with build instructions and usage guide
- Automated unit tests for monitoring and storage logic

## 9. Next Steps
1. Install Xcode 15 and command-line tools.
2. Clone or initialize Git repository.
3. Create a new SwiftUI macOS app target in Xcode.
4. Implement NSStatusBarItem with placeholder view.
5. Add pasteboard polling logic and print to console.
6. Commit first working prototype.
7. Share progress and iterate on feedback.