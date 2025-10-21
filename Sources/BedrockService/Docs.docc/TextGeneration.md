# Text Generation

Generate text using the InvokeModel API

## Overview

The InvokeModel API provides direct access to foundation models for text completion tasks. This is useful for simple text generation without the conversational context of the Converse API.

## Basic Text Generation

Generate text from a prompt:

```swift
let model: BedrockModel = .nova_micro

guard model.hasTextModality() else {
    throw MyError.incorrectModality("\(model.name) does not support text generation")
}

let textCompletion = try await bedrock.completeText(
    "Write a story about a space adventure",
    with: model
)

print(textCompletion.completion)
```

## Generation Parameters

Control text generation behavior:

```swift
let textCompletion = try await bedrock.completeText(
    "Explain quantum computing in simple terms",
    with: model,
    maxTokens: 1000,
    temperature: 0.7,
    topP: 0.9,
    topK: 250,
    stopSequences: ["THE END", "CONCLUSION"]
)

print(textCompletion.completion)
```

### Parameter Descriptions

- **maxTokens**: Maximum number of tokens to generate
- **temperature**: Controls randomness (0.0 = deterministic, 1.0 = very random)
- **topP**: Nucleus sampling threshold (0.0-1.0)
- **topK**: Limits vocabulary to top K tokens
- **stopSequences**: Strings that stop generation when encountered

## Model-Specific Parameters

Different models support different parameters:

```swift
// Check what parameters a model supports
if let textModality = model.modality as? TextModality {
    let params = textModality.getParameters()
    
    if params.temperature.isSupported {
        print("Temperature range: \(params.temperature.minValue)-\(params.temperature.maxValue ?? 1.0)")
    }
    
    if params.topK.isSupported {
        print("TopK supported with max: \(params.topK.maxValue ?? "unlimited")")
    } else {
        print("TopK not supported by this model")
    }
}
```

## Use Cases

### Creative Writing
```swift
let story = try await bedrock.completeText(
    "Once upon a time in a magical forest",
    with: model,
    temperature: 0.9, // High creativity
    maxTokens: 500
)
```

### Technical Documentation
```swift
let documentation = try await bedrock.completeText(
    "## API Reference\n\nThe authenticate() function",
    with: model,
    temperature: 0.3, // Low creativity, more factual
    maxTokens: 800
)
```

### Code Generation
```swift
let code = try await bedrock.completeText(
    "// Swift function to calculate fibonacci numbers\nfunc fibonacci(",
    with: model,
    temperature: 0.1, // Very deterministic
    stopSequences: ["\n\n", "// End"]
)
```

### Structured Output
```swift
let jsonOutput = try await bedrock.completeText(
    "Generate a JSON object representing a user profile:",
    with: model,
    temperature: 0.2,
    stopSequences: ["}"],
    maxTokens: 200
)
```

## Error Handling

Handle parameter validation and model errors:

```swift
do {
    let completion = try await bedrock.completeText(
        "Generate text",
        with: model,
        temperature: 2.0 // Invalid temperature
    )
} catch BedrockServiceError.parameterOutOfRange(let param, let value, let range) {
    print("Parameter \(param) value \(value) outside range: \(range)")
} catch BedrockServiceError.notSupported(let feature) {
    print("Feature not supported: \(feature)")
} catch {
    print("Text generation failed: \(error)")
}
```

## Comparing with Converse API

| Feature | InvokeModel (Text) | Converse API |
|---------|-------------------|--------------|
| Conversation history | ❌ | ✅ |
| System prompts | ❌ | ✅ |
| Tool calling | ❌ | ✅ |
| Vision support | ❌ | ✅ |
| Streaming | ❌ | ✅ |
| Simple text completion | ✅ | ✅ |
| Lower latency | ✅ | ❌ |

## When to Use Text Generation

Use the InvokeModel text generation API when you need:
- Simple, one-shot text completion
- Lower latency responses
- Direct control over model parameters
- No conversation context required

Use the Converse API when you need:
- Multi-turn conversations
- System prompts and instructions
- Tool calling capabilities
- Vision or document processing

## See Also

- <doc:Converse>
- <doc:Embeddings>