# Vision

Add images to your conversations

## Overview

Vision capabilities allow you to send images to foundation models for analysis, description, and question answering about visual content.

## Basic Image Analysis

Send an image with your prompt:

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality(.vision) else {
    throw MyError.incorrectModality("\(model.name) does not support vision")
}

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you tell me about this plant?")
    .withImage(format: .jpeg, source: base64EncodedImage)

let reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")
```

## Supported Image Formats

BedrockService supports common image formats:
- JPEG (`.jpeg`)
- PNG (`.png`) 
- GIF (`.gif`)
- WebP (`.webp`)

## Image with Parameters

Combine images with inference parameters:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Describe this image in detail")
    .withImage(format: .jpeg, source: base64EncodedImage)
    .withTemperature(0.8)
    .withMaxTokens(1000)

let reply = try await bedrock.converse(with: builder)
```

## Multi-turn Vision Conversations

Continue conversations that include images:

```swift
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("What type of flower is this?")
    .withImage(format: .jpeg, source: base64EncodedImage)

var reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")

// Continue without sending the image again
builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Where can I find those flowers?")

reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")
```

## Using ImageBlock

For more control, create `ImageBlock` objects directly:

```swift
let imageBlock = ImageBlock(format: .jpeg, source: base64EncodedImage)

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Analyze this image")
    .withImage(imageBlock)
```

## Streaming with Vision

Vision works seamlessly with streaming:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Describe what you see in this image")
    .withImage(format: .png, source: base64EncodedImage)

let stream = try await bedrock.converseStream(with: builder)

for try await element in stream {
    switch element {
    case .text(_, let text):
        print(text, terminator: "")
    case .messageComplete(_):
        print("\n")
    default:
        break
    }
}
```

## See Also

- <doc:Converse>
- <doc:Documents>
- <doc:Streaming>