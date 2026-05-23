# Structured Output

Constrain model responses to conform to a JSON schema

## Overview

Structured output uses constrained decoding to guarantee that model responses conform to a specified JSON schema, producing reliable machine-readable output. This is useful when you need to parse model responses programmatically — for example, extracting structured data, generating API payloads, or populating data models.

The library provides two mechanisms for structured output:

1. **JSON schema output format** — Forces the model to produce JSON conforming to a user-defined schema via the `withOutputFormat` builder method.
2. **Strict tool use** — Validates tool input parameters against their schema by setting `strict: true` on tool definitions, ensuring tool calls always produce valid inputs.

Both mechanisms integrate into the existing `ConverseRequestBuilder` fluent API pattern.

## JSON Schema Output Format

Define a JSON schema and use `withOutputFormat` to constrain the model's response:

```swift
let model: BedrockModel = .claude_sonnet_v4

guard model.hasConverseModality(.structuredOutput) else {
    throw MyError.incorrectModality("\(model.name) does not support structured output")
}

let schema = try JSON(from: """
{
    "type": "object",
    "properties": {
        "name": { "type": "string" },
        "age": { "type": "integer" },
        "email": { "type": "string", "format": "email" }
    },
    "required": ["name", "age", "email"],
    "additionalProperties": false
}
""")

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Extract the person's info from: John Doe, 30 years old, john@example.com")
    .withOutputFormat(schema: schema, name: "person_info", description: "Person information")

let reply = try await bedrock.converse(with: builder)
let jsonText = try reply.getTextReply()
// jsonText is guaranteed valid JSON matching the schema when stopReason is .endTurn
```

## Creating an OutputFormat

You can create an `OutputFormat` in several ways:

### From a JSON Value

```swift
let schema = JSON([
    "type": "object",
    "properties": [
        "title": ["type": "string"],
        "rating": ["type": "integer"]
    ],
    "required": ["title", "rating"],
    "additionalProperties": false
])

let outputFormat = try OutputFormat(schema: schema, name: "movie_review")
```

### From a JSON String

```swift
let outputFormat = try OutputFormat(
    schema: """
    {
        "type": "object",
        "properties": {
            "summary": { "type": "string" },
            "sentiment": { "type": "string", "enum": ["positive", "negative", "neutral"] }
        },
        "required": ["summary", "sentiment"],
        "additionalProperties": false
    }
    """,
    name: "text_analysis",
    description: "Structured text analysis result"
)
```

### Using OutputFormat Directly

```swift
let outputFormat = try OutputFormat(
    schema: schema,
    name: "extraction_result",
    description: "Structured extraction result"
)

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Analyze this text...")
    .withOutputFormat(outputFormat)
```

## Strict Tool Use

Mark a tool as strict to guarantee that the model's tool input parameters conform to the tool's input schema:

```swift
let tool = try Tool(
    name: "get_weather",
    inputSchema: try JSON(from: """
    {
        "type": "object",
        "properties": {
            "location": { "type": "string", "description": "City name" },
            "unit": { "type": "string", "enum": ["celsius", "fahrenheit"] }
        },
        "required": ["location", "unit"],
        "additionalProperties": false
    }
    """),
    description: "Get weather for a location",
    strict: true
)

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("What's the weather in Paris?")
    .withTool(tool)

let reply = try await bedrock.converse(with: builder)
let toolUse = try reply.getToolUse()
// toolUse.input is guaranteed to match the schema — both "location" and "unit" are present
let location: String? = toolUse.input["location"]
let unit: String? = toolUse.input["unit"]
```

When `strict` is omitted or set to `false`, the tool behaves as before — the model may produce inputs that don't fully conform to the schema.

## Streaming with Structured Output

Structured output works with streaming. The model streams partial JSON tokens, and the complete response conforms to the schema:

```swift
let bookListSchema = try JSON(from: """
{
    "type": "object",
    "properties": {
        "books": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "title": { "type": "string" },
                    "author": { "type": "string" },
                    "year": { "type": "integer" }
                },
                "required": ["title", "author", "year"],
                "additionalProperties": false
            }
        }
    },
    "required": ["books"],
    "additionalProperties": false
}
""")

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("List 3 classic science fiction books")
    .withOutputFormat(schema: bookListSchema, name: "book_list")

let stream = try await bedrock.converseStream(with: builder)

for try await element in stream.stream {
    switch element {
    case .text(_, let delta):
        print(delta, terminator: "")  // Partial JSON streamed incrementally
    case .messageComplete(let message):
        // Full message available — text is valid JSON when stopReason is .endTurn
        if message.stopReason == .endTurn {
            print("\n\nResponse conforms to schema.")
        }
    default:
        break
    }
}
```

## Stop Reason Handling

Structured output guarantees schema conformance only when the model finishes normally. Check the `stopReason` to determine whether the response is safe to parse:

```swift
let reply = try await bedrock.converse(with: builder)
let lastMessage = reply.getLastMessage()

switch lastMessage.stopReason {
case .endTurn:
    // Response conforms to the schema — safe to parse as JSON
    let json = try reply.getTextReply()
    print("Valid JSON: \(json)")

case .maxTokens:
    // Response was truncated — may be incomplete or invalid JSON
    let partial = try reply.getTextReply()
    print("Warning: response truncated, may not be valid JSON")

case .contentFiltered:
    // Content filter intervened — response may not conform
    print("Warning: content was filtered")

case .guardrailIntervened:
    // Guardrail intervened — response may not conform
    print("Warning: guardrail intervened")

default:
    break
}
```

To avoid truncation, ensure `maxTokens` is large enough for the expected response size, or omit it to use the model's default.

## Best Practices for Schema Design

Follow these guidelines for reliable structured output:

- **Always set `additionalProperties: false`** — This prevents the model from adding unexpected fields to the response. Without it, the model may include extra properties that your parsing code doesn't expect.

- **Mark all fields as required** — List every property in the `required` array. Optional fields can lead to inconsistent responses across calls.

- **Use specific types and enums** — Constrain values with `enum` arrays and specific types (`integer` vs `number`) to reduce ambiguity.

- **Keep schemas focused** — Smaller, well-defined schemas produce more consistent results than large, deeply nested ones.

- **Use descriptive property names** — Clear names help the model understand what data to extract without needing additional prompt instructions.

Example of a well-designed schema:

```swift
let schema = try JSON(from: """
{
    "type": "object",
    "properties": {
        "city": { "type": "string" },
        "country": { "type": "string" },
        "population": { "type": "integer" },
        "climate": { "type": "string", "enum": ["tropical", "arid", "temperate", "continental", "polar"] }
    },
    "required": ["city", "country", "population", "climate"],
    "additionalProperties": false
}
""")
```

## See Also

- <doc:Converse>
- <doc:Tools>
- <doc:Streaming>
