// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ClipboardHistory",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "ClipboardHistory",
            path: "Sources/ClipboardHistory",
            resources: [
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "ClipboardHistoryTests",
            dependencies: ["ClipboardHistory"],
            path: "ClipboardHistoryTests"
        ),
    ]
)
