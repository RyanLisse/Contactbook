// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Contactbook",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .executable(name: "contactbook", targets: ["ContactbookExec"]),
        .library(name: "ContactbookCLI", targets: ["ContactbookCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "ContactbookCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "MCP", package: "swift-sdk"),
            ],
            path: "Sources/ContactbookCLI"
        ),
        .executableTarget(
            name: "ContactbookExec",
            dependencies: ["ContactbookCLI"],
            path: "Sources/ContactbookExec"
        ),
        .testTarget(
            name: "ContactbookTests",
            dependencies: ["ContactbookCLI"],
            path: "Tests/ContactbookTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
