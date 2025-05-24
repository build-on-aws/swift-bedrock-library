// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBedrock",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    products: [
        .executable(name: "PlaygroundAPI", targets: ["PlaygroundAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/sebsto/swift-bedrock-library.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "PlaygroundAPI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "BedrockService", package: "swift-bedrock-library"),
            ],
            path: "Sources/PlaygroundAPI"
        )
    ]
)
