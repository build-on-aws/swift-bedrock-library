# Swift Bedrock Library

A Swift library for interacting with [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html) foundation models.

📖 **[Complete Documentation](https://swiftpackageindex.com/build-on-aws/swift-bedrock-library)** - Comprehensive guides and API reference

## TL;DR - Quick Start

```swift
import BedrockService

// Initialize the service
let bedrock = try await BedrockService(region: .uswest2)

// Send a simple text prompt
let model: BedrockModel = .nova_lite
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Tell me about rainbows")

let reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")
```

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/build-on-aws/swift-bedrock-library.git", from: "1.5.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "BedrockService", package: "swift-bedrock-library")
        ]
    )
]
```

Requires: `platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)]`

## Documentation

📖 **[Complete Documentation](https://swiftpackageindex.com/build-on-aws/swift-bedrock-library)** - Comprehensive guides and API reference

Key topics:
- [Authentication](https://swiftpackageindex.com/build-on-aws/swift-bedrock-library/documentation/bedrockservice/authentication) - Configure AWS credentials
- [Converse API](https://swiftpackageindex.com/build-on-aws/swift-bedrock-library/documentation/bedrockservice/converse) - Conversational AI
- [Image Generation](https://swiftpackageindex.com/build-on-aws/swift-bedrock-library/documentation/bedrockservice/imagegeneration) - Create and modify images
- [Tools](https://swiftpackageindex.com/build-on-aws/swift-bedrock-library/documentation/bedrockservice/tools) - Function calling
- [Streaming](https://swiftpackageindex.com/build-on-aws/swift-bedrock-library/documentation/bedrockservice/streaming) - Real-time responses

## Examples

Explore the [Examples](./Examples/) directory for complete sample applications including:
- Basic conversation chat
- Streaming responses
- Image generation
- iOS math solver app
- Web playground with frontend/backend

## Acknowledgment

This library and playground have been written by [Mona Dierickx](https://www.linkedin.com/in/mona-dierickx/), during her last year of studies at [HoGent](https://www.hogent.be/), Belgium.

Thank you for your enthusiasm and positive attitude during the three months we worked together (February 2025 - May 2025).

Thank you Professor Steven Van Impe for allowing us to work with these young talents.
