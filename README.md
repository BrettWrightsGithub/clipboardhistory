# ClipboardHistory

A lightweight macOS menu bar app that keeps your clipboard history searchable and accessible.

## Features

- 📋 **Menu bar app** — lives in your status bar, no dock icon
- ⌨️ **Global hotkey** — Option+V toggles the history popover
- 🔍 **Search** — filter through your clipboard entries
- 📌 **Pin** — keep important entries at the top
- 📎 **Auto-paste** — select an entry and it pastes directly into your active app
- ⚙️ **Preferences** — configurable max items, retention period, launch at login
- 💾 **Persistent storage** — Core Data backed, survives restarts
- ⌨️ **Keyboard navigation** — arrow keys + Enter to select

## Requirements

- macOS 12 (Monterey) or later
- **Accessibility permissions** required (for global hotkey and auto-paste)

## Install

### Build from source

```bash
git clone https://github.com/BrettWrightsGithub/clipboardhistory.git
cd clipboardhistory
make release
```

The binary will be at `.build/release/ClipboardHistory`.

### Run

```bash
.build/release/ClipboardHistory
```

Or copy to your Applications or /usr/local/bin:

```bash
make install
```

### Open in Xcode

```bash
open Package.swift
```

## Granting Accessibility Permissions

On first launch, macOS will ask for Accessibility access. If it doesn't:

1. Open **System Settings → Privacy & Security → Accessibility**
2. Click the **+** button
3. Add `ClipboardHistory` (from wherever you built/installed it)
4. Enable the toggle

This is required for the global hotkey (Option+V) and auto-paste to work.

## Usage

1. Launch the app — it appears as a clipboard icon in your menu bar
2. Copy things normally (Cmd+C)
3. Press **Option+V** to open your clipboard history
4. Click an entry or use arrow keys + Enter to paste it
5. Right-click entries to pin or delete them
6. Access **Preferences** via the Settings menu for retention and storage options

## Tech Stack

- Swift / SwiftUI
- Core Data (SQLite persistence)
- Carbon.HIToolbox (global hotkey)
- CGEvent (auto-paste simulation)

## License

MIT — see [LICENSE](LICENSE)
