// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InvokeModel",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    products: [
        .executable(name: "InvokeModel", targets: ["InvokeModel"])
    ],
    dependencies: [
        // for production use, uncomment the following line
        // .package(url: "https://github.com/build-on-aws/swift-bedrock-library.git", branch: "main"),

        // for local development, use the following line
        .package(name: "swift-bedrock-library", path: "../.."),

        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "InvokeModel",
            dependencies: [
                .product(name: "BedrockService", package: "swift-bedrock-library"),
                .product(name: "Logging", package: "swift-log"),
            ]
        )
    ]
)
