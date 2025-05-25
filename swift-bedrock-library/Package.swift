// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBedrockLibrary",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    products: [
        .library(name: "BedrockService", targets: ["BedrockService"]),
        .library(name: "BedrockTypes", targets: ["BedrockTypes"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "1.3.3"),
        .package(url: "https://github.com/smithy-lang/smithy-swift", from: "0.118.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/awslabs/aws-crt-swift", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "BedrockService",
            dependencies: [
                .target(name: "BedrockTypes"),
                .product(name: "AWSClientRuntime", package: "aws-sdk-swift"),
                .product(name: "AWSBedrock", package: "aws-sdk-swift"),
                .product(name: "AWSBedrockRuntime", package: "aws-sdk-swift"),
                .product(name: "Smithy", package: "smithy-swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AwsCommonRuntimeKit", package: "aws-crt-swift"),
            ],
            path: "Sources/BedrockService"
        ),
        .target(
            name: "BedrockTypes",
            dependencies: [
                .product(name: "AWSBedrockRuntime", package: "aws-sdk-swift"),
                .product(name: "AWSBedrock", package: "aws-sdk-swift"),
                .product(name: "Smithy", package: "smithy-swift"),
            ],
            path: "Sources/BedrockTypes"
        ),
        .testTarget(
            name: "BedrockServiceTests",
            dependencies: [
                .target(name: "BedrockService"),
                .target(name: "BedrockTypes"),
            ],
            path: "Tests/BedrockServiceTests"
        ),
        .testTarget(
            name: "BedrockTypesTests",
            dependencies: [
                .target(name: "BedrockTypes")
            ],
            path: "Tests/BedrockTypesTests"
        ),
    ]
)
