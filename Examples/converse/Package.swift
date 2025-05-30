// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Converse",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    products: [
        .executable(name: "Converse", targets: ["Converse"])
    ],
    dependencies: [
        .package(url: "https://github.com/build-on-aws/swift-bedrock-library.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Converse",
            dependencies: [
                .product(name: "BedrockService", package: "swift-bedrock-library"),
                .product(name: "Logging", package: "swift-log"),
            ]
        )
    ]
)
