// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClipboardHistory",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "ClipboardHistory", targets: ["ClipboardHistory"])
    ],
    dependencies: [
        // No external dependencies for now
    ],
    targets: [
        .executableTarget(
            name: "ClipboardHistory",
            path: "Sources/ClipboardHistory",
            resources: [
                .process("Assets.xcassets")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .unsafeFlags(["-application-extension"], .when(configuration: .release))
            ]
        ),
        .testTarget(
            name: "ClipboardHistoryTests",
            dependencies: ["ClipboardHistory"],
            path: "Tests/ClipboardHistoryTests"
        ),
        .testTarget(
            name: "ClipboardHistoryUITests",
            dependencies: ["ClipboardHistory"],
            path: "Tests/ClipboardHistoryUITests"
        )
    ]
)
