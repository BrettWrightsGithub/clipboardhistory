# ClipboardHistory

A macOS clipboard history application that lets you view and manage your clipboard history.

## Project Structure

This project has been rebuilt using Swift Package Manager to fix issues with the Xcode project structure. The original Xcode project was using incompatible settings causing errors like "didn't find classname for 'isa' key".

### Directory Structure

- `Sources/ClipboardHistory/` - Main application source code
- `Tests/ClipboardHistoryTests/` - Unit tests
- `Tests/ClipboardHistoryUITests/` - UI tests
- `Config/` - Configuration files including Info.plist and entitlements

## Building the Project

You can build the project using Swift Package Manager:

```bash
cd ClipboardHistoryFixed
swift build
```

## Running Tests

Tests can be run with:

```bash
cd ClipboardHistoryFixed
swift test
```

## Running the Application

To run the application:

```bash
cd ClipboardHistoryFixed
swift run
```

## Opening in Xcode

You can open this Swift package directly in Xcode without generating a project file. Just open the `Package.swift` in Xcode:

```bash
open Package.swift
```

Or within Xcode select **File → Open…**, navigate to the `ClipboardHistoryFixed` folder, and pick `Package.swift`.
