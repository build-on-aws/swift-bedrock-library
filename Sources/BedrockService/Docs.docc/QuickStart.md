# Quick Start

Get up and running with BedrockService in minutes

## Overview

This guide will help you quickly set up and start using BedrockService in your Swift project.

## Installation

Add BedrockService to your Swift package:

```bash
swift package add-dependency https://github.com/build-on-aws/swift-bedrock-library.git --branch main
swift package add-target-dependency BedrockService TargetName --package swift-bedrock-library
```

Update your `Package.swift` to include platform requirements:

```swift
import PackageDescription

let package = Package(
    name: "ProjectName",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    dependencies: [
        .package(url: "https://github.com/build-on-aws/swift-bedrock-library.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "TargetName",
            dependencies: [
                .product(name: "BedrockService", package: "swift-bedrock-library"),
            ]
        )
    ]
)
```

## Basic Usage

```swift
import BedrockService

// Initialize the service
let bedrock = try await BedrockService(region: .uswest2)

// List available models
let models = try await bedrock.listModels()

// Send a simple text prompt
let model: BedrockModel = .nova_lite
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Tell me about rainbows")

let reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")
```

## Next Steps

- Learn about different <doc:Authentication> methods
- Explore <doc:Converse> for conversational AI
- Try <doc:ImageGeneration> for creating images
- Check out <doc:Tools> for function calling