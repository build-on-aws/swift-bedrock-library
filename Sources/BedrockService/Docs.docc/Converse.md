# Converse API

Build conversational AI applications with the Converse API

## Overview

The Converse API provides a unified interface for text-based interactions with foundation models. It supports multi-turn conversations, system prompts, and maintains conversation history automatically.

## Basic Text Conversation

Start a simple conversation with a foundation model:

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality() else {
    throw MyError.incorrectModality("\(model.name) does not support converse")
}

var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Tell me about rainbows")

var reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")

// Continue the conversation
builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Do you think birds can see them too?")

reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")
```

## Inference Parameters

Control the model's behavior with inference parameters:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Tell me about rainbows")
    .withMaxTokens(512)
    .withTemperature(0.2)
    .withStopSequences(["END", "STOP"])
    .withSystemPrompts(["Be concise", "Use simple language"])

let reply = try await bedrock.converse(with: builder)
```

## System Prompts

Guide the model's behavior with system prompts:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withSystemPrompts([
        "You are a helpful assistant",
        "Always provide accurate information",
        "Be concise in your responses"
    ])
    .withPrompt("What is machine learning?")
```

## Custom Messages

Build messages manually for more control:

```swift
// Simple text message
let reply = try await bedrock.converse(
    with: model,
    conversation: [Message("What day of the week is it?")]
)

// With inference parameters
let reply = try await bedrock.converse(
    with: model,
    conversation: [Message("What day of the week is it?")],
    maxTokens: 512,
    temperature: 1,
    topP: 0.8,
    stopSequences: ["THE END"],
    systemPrompts: ["Today is Wednesday, make sure to mention that."]
)
```

## See Also

- <doc:Streaming>
- <doc:Vision>
- <doc:Documents>
- <doc:Tools>
- <doc:Reasoning>