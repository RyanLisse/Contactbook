// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "contactbook",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .executable(name: "contactbook", targets: ["Executable"]),
        .library(name: "ContactbookCore", targets: ["Core"]),
        .library(name: "ContactbookCLI", targets: ["CLI"]),
        .library(name: "ContactbookMCP", targets: ["ContactbookMCP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk", from: "0.9.0"),
        .package(url: "https://github.com/steipete/Commander", from: "0.2.0"),
    ],
    targets: [
        // Core library - framework-agnostic, no CLI dependencies
        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/Core",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ]
        ),

        // CLI executable
        .executableTarget(
            name: "Executable",
            dependencies: ["CLI"],
            path: "Sources/Executable",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ]
        ),

        // CLI library - commands using ArgumentParser
        .target(
            name: "CLI",
            dependencies: [
                "Core",
                "ContactbookMCP",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Commander", package: "Commander"),
            ],
            path: "Sources/CLI",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ]
        ),

        // MCP library - server with handler pattern
        .target(
            name: "ContactbookMCP",
            dependencies: [
                "Core",
                .product(name: "MCP", package: "swift-sdk"),
            ],
            path: "Sources/MCP",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
