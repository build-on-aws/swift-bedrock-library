# Anthropic Messages API

Use Anthropic models on Amazon Bedrock via the Messages API

## Overview

The Messages API provides access to Anthropic models hosted on Amazon Bedrock through the `bedrock-mantle` endpoint. This API uses the native Anthropic Messages protocol at `/anthropic/v1/messages` and supports multi-turn conversations.

Like the Responses API, the Messages API requires explicit authentication — you pass a ``BedrockAuthentication`` value directly to the call.

## Supported Models

| Model | Identifier |
|-------|-----------|
| Claude Fable 5 | `.claude_fable_v5` |

## Prerequisites

Claude Fable 5 requires a one-time data retention opt-in before use. Set the retention mode to `provider_data_share` via one of:

```bash
# With API Key:
curl -X PUT https://bedrock-mantle.us-east-1.api.aws/v1/data_retention \
  -H "x-api-key: <your-bedrock-api-key>" \
  -H "Content-Type: application/json" \
  -d '{ "mode": "provider_data_share" }'

# With SigV4 (IAM credentials):
eval $(aws configure export-credentials --profile <profile> --format env) && \
curl -X PUT https://bedrock.us-east-1.amazonaws.com/data-retention \
  -H "Content-Type: application/json" \
  -d '{"mode":"provider_data_share"}' \
  --aws-sigv4 "aws:amz:us-east-1:bedrock" \
  --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
  -H "x-amz-security-token: $AWS_SESSION_TOKEN"
```

## Basic Usage

Send a single prompt and receive a text response:

```swift
let bedrock = try await BedrockService(region: .useast1)

let reply = try await bedrock.createMessage(
    "Explain quantum computing in simple terms",
    with: .claude_fable_v5,
    authentication: .default
)

print("Response: \(reply.text)")
print("Tokens: \(reply.usage.inputTokens) in / \(reply.usage.outputTokens) out")
```

## Multi-Turn Conversations

The Messages API is stateless — you send the full conversation history with each request. Use the `[AnthropicMessage]` overload and `MessagesOutput.asMessage` to build up conversations:

```swift
let bedrock = try await BedrockService(region: .useast1)

// Start a conversation
var conversation: [AnthropicMessage] = [
    AnthropicMessage(role: .user, content: "What is quantum computing?")
]

let reply1 = try await bedrock.createMessage(
    conversation,
    with: .claude_fable_v5,
    authentication: .default
)

// Append the assistant's reply and ask a follow-up
conversation.append(reply1.asMessage)
conversation.append(AnthropicMessage(role: .user, content: "Can you give a real-world example?"))

let reply2 = try await bedrock.createMessage(
    conversation,
    with: .claude_fable_v5,
    authentication: .default
)

print(reply2.text)
```

## Authentication

The Messages API supports the same authentication methods as the rest of the library (see <doc:Authentication>).

### API Key (Bearer Token)

```swift
let reply = try await bedrock.createMessage(
    "Hello!",
    with: .claude_fable_v5,
    authentication: .apiKey(key: "your-api-key")
)
```

> Important: Never hardcode API keys in your application. Use environment variables or secure storage.

### SigV4 (AWS Credentials)

```swift
// Default credential chain
let reply = try await bedrock.createMessage(
    "Hello!",
    with: .claude_fable_v5,
    authentication: .default
)

// Named profile
let reply = try await bedrock.createMessage(
    "Hello!",
    with: .claude_fable_v5,
    authentication: .profile(profileName: "my-profile")
)
```

## Controlling Max Tokens

Specify the maximum number of tokens in the response:

```swift
let reply = try await bedrock.createMessage(
    "Write a haiku about Swift",
    with: .claude_fable_v5,
    maxTokens: 256,
    authentication: .default
)
```

## Response Structure

The ``MessagesOutput`` contains:

- `id` — Unique message identifier
- `text` — The model's text reply
- `model` — The model identifier string returned by the API
- `stopReason` — Why generation stopped (`end_turn`, `max_tokens`, `refusal`)
- `usage` — Token usage with `inputTokens` and `outputTokens`
- `asMessage` — Convenience property returning an ``AnthropicMessage`` for conversation building

## Content Restrictions

Claude Fable 5 includes blocking classifiers for dual-use content. When a request is blocked, the response will have `stopReason` set to `"refusal"`. Handle this as a primary response path:

```swift
let reply = try await bedrock.createMessage(
    prompt,
    with: .claude_fable_v5,
    authentication: .default
)

if reply.stopReason == "refusal" {
    print("Request was refused by safety classifiers")
} else {
    print(reply.text)
}
```

## Model Characteristics

Claude Fable 5 has specific constraints:

| Parameter | Constraint |
|-----------|-----------|
| Context window | 1,000,000 tokens |
| Max output | 128,000 tokens |
| Temperature | Must be 1.0 or unset |
| top_p | Must be ≥ 0.99 and < 1.0, or unset |
| top_k | Not supported |
| Reasoning | Always on (adaptive thinking cannot be disabled) |

## See Also

- <doc:Authentication>
- <doc:Converse>
- <doc:Responses>
- <doc:Reasoning>
