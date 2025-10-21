# Streaming

Get real-time responses with streaming

## Overview

Streaming allows you to receive model responses in real-time as they're generated, providing a better user experience for interactive applications.

## Basic Streaming

Use the same `ConverseRequestBuilder` with `converseStream`:

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality(.streaming) else {
    throw MyError.incorrectModality("\(model.name) does not support streaming")
}

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Tell me about rainbows")

let reply = try await bedrock.converseStream(with: builder)

for try await element in reply.stream {
    switch element {
    case .messageStart(let role):
        print("Message started with role: \(role)")
        
    case .text(_, let text):
        print(text, terminator: "")
        
    case .messageComplete(_):
        print("\n")
        
    case .metaData(let metaData):
        print("Metadata: \(metaData)")
        
    default:
        break
    }
}
```

## Stream Elements

The stream provides different types of elements:

- `.messageStart(Role)` - Beginning of a message
- `.text(Int, String)` - Partial text content with index
- `.reasoning(Int, String)` - Partial reasoning content with index  
- `.toolUse(Int, ToolUseBlock)` - Complete tool use response
- `.messageComplete(Message)` - Complete message with all content
- `.metaData(ResponseMetadata)` - Response metadata including token usage

## Interactive Chat Loop

Build an interactive chat application:

```swift
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Introduce yourself")

while true {
    let stream = try await bedrock.converseStream(with: builder)
    var assistantMessage: Message = Message("empty")
    
    for try await element in stream {
        switch element {
        case .text(_, let text):
            print(text, terminator: "")
            
        case .messageComplete(let message):
            assistantMessage = message
            print("\n")
            
        default:
            break
        }
    }
    
    print("You: ")
    guard let prompt = readLine(), prompt != "quit" else { break }
    
    builder = try ConverseRequestBuilder(from: builder, with: assistantMessage)
        .withPrompt(prompt)
}
```

## Low-Level Stream Access

For maximum control, access the raw AWS SDK stream:

```swift
let reply = try await bedrock.converseStream(with: builder)
// Access reply.rawStream for the low-level AWS SDK stream
```

## See Also

- <doc:Converse>
- <doc:Tools>
- <doc:Reasoning>