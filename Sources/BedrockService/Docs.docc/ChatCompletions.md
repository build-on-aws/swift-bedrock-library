# Chat Completions API

Use Google Gemma models on Amazon Bedrock via the OpenAI-compatible Chat Completions API

## Overview

The Chat Completions API provides access to Google Gemma models hosted on Amazon Bedrock through the `bedrock-mantle` endpoint. This API uses the OpenAI-compatible chat completions protocol and supports multi-turn conversations.

Like the Responses and Messages APIs, the Chat Completions API requires explicit authentication — you pass a ``BedrockAuthentication`` value directly to the call.

## Supported Models

| Model | Identifier | Endpoint |
|-------|-----------|----------|
| Gemma 4 31B | `.gemma4_31b` | `/openai/v1/chat/completions` |
| Gemma 4 26B-A4B | `.gemma4_26b_a4b` | `/openai/v1/chat/completions` |
| Gemma 4 E2B | `.gemma4_e2b` | `/openai/v1/chat/completions` |
| Gemma 3 27B IT | `.gemma3_27b_it` | `/v1/chat/completions` |
| Gemma 3 12B IT | `.gemma3_12b_it` | `/v1/chat/completions` |
| Gemma 3 4B IT | `.gemma3_4b_it` | `/v1/chat/completions` |

> Note: Gemma 4 models are **mantle-only** — they support Chat Completions and Responses APIs but not InvokeModel or Converse. Gemma 3 models support Chat Completions, InvokeModel (``BedrockService/completeText(_:with:maxTokens:temperature:topP:topK:stopSequences:serviceTier:)``), and the Converse API.

## Basic Usage

Send a single prompt and receive a text response:

```swift
let bedrock = try await BedrockService(region: .useast1)

let reply = try await bedrock.completeChatCompletion(
    "Explain quantum computing in simple terms",
    with: .gemma4_31b,
    authentication: .default
)

print("Response: \(reply.text)")
print("Tokens: \(reply.usage.promptTokens) in / \(reply.usage.completionTokens) out")
```

## Multi-Turn Conversations

The Chat Completions API is stateless — you send the full conversation history with each request. The library provides convenience `append` overloads on `[ChatCompletionsMessage]` so you can append a `String` (as a user message) or a ``ChatCompletionsOutput`` (as an assistant message) directly:

```swift
let bedrock = try await BedrockService(region: .useast1)

// Start a conversation
var messages: [ChatCompletionsMessage] = []
messages.append("What is quantum computing?")

let reply1 = try await bedrock.completeChatCompletion(
    messages,
    with: .gemma4_31b,
    authentication: .default
)

// Append the assistant's reply and ask a follow-up
messages.append(reply1)
messages.append("Can you give a real-world example?")

let reply2 = try await bedrock.completeChatCompletion(
    messages,
    with: .gemma4_31b,
    authentication: .default
)

print(reply2.text)
```

## System Prompts

Use the `.system` role to set the assistant's behavior:

```swift
var messages: [ChatCompletionsMessage] = [
    ChatCompletionsMessage(role: .system, content: "You are a concise technical writer.")
]
messages.append("What is Swift concurrency?")

let reply = try await bedrock.completeChatCompletion(
    messages,
    with: .gemma4_31b,
    authentication: .default
)
```

## Authentication

The Chat Completions API supports the same authentication methods as the rest of the library (see <doc:Authentication>).

### API Key (Bearer Token)

```swift
let reply = try await bedrock.completeChatCompletion(
    "Hello!",
    with: .gemma4_31b,
    authentication: .apiKey(key: "your-api-key")
)
```

> Important: Never hardcode API keys in your application. Use environment variables or secure storage.

### SigV4 (AWS Credentials)

```swift
// Default credential chain
let reply = try await bedrock.completeChatCompletion(
    "Hello!",
    with: .gemma4_31b,
    authentication: .default
)

// Named profile
let reply = try await bedrock.completeChatCompletion(
    "Hello!",
    with: .gemma4_31b,
    authentication: .profile(profileName: "my-profile")
)
```

## Controlling Generation Parameters

Specify temperature, top-p, and max tokens:

```swift
let reply = try await bedrock.completeChatCompletion(
    "Write a haiku about Swift",
    with: .gemma4_31b,
    maxTokens: 256,
    temperature: 0.7,
    authentication: .default
)
```

> Important: Temperature and top-p are mutually exclusive. Providing both throws a `notSupported` error. Top-k is not supported for Gemma models.

| Parameter | Range | Default |
|-----------|-------|---------|
| temperature | 0 – 2 | 1 |
| maxTokens | 1 – 8192 | 8192 |
| topP | 0 – 1 | 1 |
| topK | — | Not supported |

## Response Structure

The ``ChatCompletionsOutput`` contains:

- `id` — Unique completion identifier
- `text` — The model's generated text (from the first choice)
- `model` — The model identifier string returned by the API
- `usage` — Token usage with `promptTokens`, `completionTokens`, and `totalTokens`

## Gemma 3 via InvokeModel

Gemma 3 models also support the traditional `completeText` path via bedrock-runtime:

```swift
let completion: TextCompletion = try await bedrock.completeText(
    "Explain recursion",
    with: .gemma3_27b_it
)

print(completion.completion)
```

## Gemma 4 via Responses API

Gemma 4 models also support the Responses API for extended features:

```swift
let response = try await bedrock.createResponse(
    "What are three benefits of open-source software?",
    with: .gemma4_31b,
    authentication: .default
)

print(response.text)
```

## See Also

- <doc:Authentication>
- <doc:Responses>
- <doc:Messages>
- <doc:TextGeneration>
