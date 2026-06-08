# OpenAI Responses API

Use OpenAI models on Amazon Bedrock via the Responses API

## Overview

The Responses API provides access to OpenAI models hosted on Amazon Bedrock through the `bedrock-mantle` endpoint. This API uses a different protocol than the Converse API and supports models like GPT 5.5 and GPT 5.4.

The Responses API requires explicit authentication — you pass a ``BedrockAuthentication`` value directly to the call, supporting both API key (Bearer token) and SigV4 credential-based authentication.

## Supported Models

The following OpenAI models support the Responses API:

| Model | Identifier |
|-------|-----------|
| GPT 5.5 | `.openai_gpt_5_5` |
| GPT 5.4 | `.openai_gpt_5_4` |

## Basic Usage

Send a single prompt and receive a text response:

```swift
let bedrock = try await BedrockService(region: .useast2)

let reply = try await bedrock.createResponse(
    "Explain quantum computing in simple terms",
    with: .openai_gpt_5_5,
    authentication: .default
)

print("Response: \(reply.text)")
print("Tokens: \(reply.usage.inputTokens) in / \(reply.usage.outputTokens) out")
```

## Authentication

The Responses API supports the same authentication methods as the rest of the library (see <doc:Authentication>). You pass a ``BedrockAuthentication`` value directly to `createResponse`:

### API Key (Bearer Token)

Use an API key generated from the AWS Bedrock console:

```swift
let reply = try await bedrock.createResponse(
    "Hello!",
    with: .openai_gpt_5_5,
    authentication: .apiKey(key: "your-api-key")
)
```

> Important: Never hardcode API keys in your application. Use environment variables or secure storage.

### SigV4 (AWS Credentials)

Use any AWS credential method — the library resolves credentials and signs requests with SigV4:

```swift
// Default credential chain
let reply = try await bedrock.createResponse(
    "Hello!",
    with: .openai_gpt_5_5,
    authentication: .default
)

// Named profile
let reply = try await bedrock.createResponse(
    "Hello!",
    with: .openai_gpt_5_5,
    authentication: .profile(profileName: "my-profile")
)
```

## Disabling Storage

By default, the server decides whether to store responses for multi-turn conversations. You can explicitly disable storage:

```swift
let reply = try await bedrock.createResponse(
    "What is the capital of France?",
    with: .openai_gpt_5_4,
    authentication: .default,
    store: false
)
```

## Response Structure

The ``ResponsesOutput`` contains:

- `id` — Unique response identifier
- `text` — The model's text reply
- `model` — The ``BedrockModel`` that generated the response
- `usage` — Token usage with `inputTokens` and `outputTokens`

```swift
let reply = try await bedrock.createResponse(
    "Tell me a joke",
    with: .openai_gpt_5_5,
    authentication: .default
)

print("ID: \(reply.id)")
print("Model: \(reply.model.name)")
print("Text: \(reply.text)")
print("Input tokens: \(reply.usage.inputTokens)")
print("Output tokens: \(reply.usage.outputTokens)")
```

## See Also

- <doc:Authentication>
- <doc:TextGeneration>
- <doc:Converse>
