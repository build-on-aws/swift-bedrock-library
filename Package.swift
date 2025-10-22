// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBedrockLibrary",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    products: [
        .library(name: "BedrockService", targets: ["BedrockService"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "1.5.51"),
        .package(url: "https://github.com/smithy-lang/smithy-swift", from: "0.158.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.4"),
        .package(url: "https://github.com/awslabs/aws-crt-swift", from: "0.53.0"),
    ],
    targets: [
        .target(
            name: "BedrockService",
            dependencies: [
                .product(name: "AWSClientRuntime", package: "aws-sdk-swift"),
                .product(name: "AWSBedrock", package: "aws-sdk-swift"),
                .product(name: "AWSBedrockRuntime", package: "aws-sdk-swift"),
                .product(name: "AWSSSOOIDC", package: "aws-sdk-swift"),
                .product(name: "Smithy", package: "smithy-swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AwsCommonRuntimeKit", package: "aws-crt-swift"),
            ]
        ),
        .testTarget(
            name: "BedrockServiceTests",
            dependencies: [
                .target(name: "BedrockService")
            ]
        ),
    ]
)
