# Implementation Plan: Gemma 4 Model Support

## Overview

Add all six Google Gemma models to the Swift Bedrock Library by introducing a new `ChatCompletionsModality` protocol, creating a `Google/` provider directory with `Gemma4Text` and `Gemma3Text` modality structs, adding the `completeChatCompletion` service method, and defining model constants with `rawValue` resolution. The implementation follows existing patterns established by OpenAI, DeepSeek, and Claude models.

## Tasks

- [x] 1. Define ChatCompletionsModality protocol and BedrockModel extensions
  - [x] 1.1 Create `ChatCompletionsModality` protocol in `Sources/BedrockService/BedrockRuntimeClient/Modalities/ChatCompletionsModality.swift`
    - Define `ChatCompletionsModality` extending `Modality` with `getChatCompletionsPath() -> String` and `getTextGenerationParameters() -> TextGenerationParameters` methods
    - Follow the same minimal pattern as `ResponsesModality.swift`
    - _Requirements: 9.1_

  - [x] 1.2 Add `hasChatCompletionsModality()` and `getChatCompletionsModality()` methods to `BedrockModel` in `Sources/BedrockService/Models/BedrockModel.swift`
    - Add `hasChatCompletionsModality() -> Bool` using protocol cast pattern
    - Add `getChatCompletionsModality() throws -> any ChatCompletionsModality` with `invalidModality` error on failure
    - Follow the exact pattern of existing `hasResponsesModality()` / `getResponsesModality()`
    - _Requirements: 9.2, 9.3, 9.4_

- [x] 2. Create Google provider directory and modality structs
  - [x] 2.1 Create `Sources/BedrockService/Models/Google/Google.swift` with `Gemma4Text` and `Gemma3Text` structs
    - `Gemma4Text` conforms to `ChatCompletionsModality` and `ResponsesModality`
    - `Gemma4Text.getChatCompletionsPath()` returns `/openai/v1/chat/completions`
    - `Gemma4Text.getResponsesPath()` returns `/openai/v1/responses`
    - `Gemma3Text` conforms to `TextModality`, `ConverseModality`, and `ChatCompletionsModality`
    - `Gemma3Text.getChatCompletionsPath()` returns `/v1/chat/completions`
    - `Gemma3Text.getTextRequestBody()` creates `OpenAIRequestBody` with topK/topP+temperature validation
    - `Gemma3Text.getTextResponseBody()` decodes `OpenAIResponseBody`
    - `Gemma3Text` supports converse features: `.textGeneration`, `.vision`, `.systemPrompts`
    - Follow the structural pattern of `DeepSeek.swift` and `OpenAI.swift`
    - _Requirements: 7.1–7.9, 8.1–8.9, 13.4, 14.1–15.11, 16.1–16.3, 17.1–17.6, 19.3, 19.4, 19.5, 20.1–20.5_

  - [x] 2.2 Create `Sources/BedrockService/Models/Google/GoogleBedrockModels.swift` with six model static constants
    - Define `gemma4_31b` (id: `google.gemma-4-31b`, name: `Gemma 4 31B`, modality: `Gemma4Text`)
    - Define `gemma4_26b_a4b` (id: `google.gemma-4-26b-a4b`, name: `Gemma 4 26B-A4B`, modality: `Gemma4Text`)
    - Define `gemma4_e2b` (id: `google.gemma-4-e2b`, name: `Gemma 4 E2B`, modality: `Gemma4Text`)
    - Define `gemma3_27b_it` (id: `google.gemma-3-27b-it`, name: `Gemma 3 27B IT`, modality: `Gemma3Text`)
    - Define `gemma3_12b_it` (id: `google.gemma-3-12b-it`, name: `Gemma 3 12B IT`, modality: `Gemma3Text`)
    - Define `gemma3_4b_it` (id: `google.gemma-3-4b-it`, name: `Gemma 3 4B IT`, modality: `Gemma3Text`)
    - All models use temperature [0, 2] default 1, maxTokens [1, 8192] default 8192, topP [0, 1] default 1, topK not supported, stopSequences not supported
    - Follow the pattern of `OpenAIBedrockModels.swift`
    - _Requirements: 1.1–1.5, 2.1–2.4, 3.1–3.4, 4.1–4.5, 5.1–5.5, 6.1–6.5, 19.1, 19.2_

  - [x] 2.3 Add six new cases to `BedrockModel.init?(rawValue:)` in `Sources/BedrockService/Models/BedrockModel.swift`
    - Add `case BedrockModel.gemma4_31b.id: self = BedrockModel.gemma4_31b`
    - Add `case BedrockModel.gemma4_26b_a4b.id: self = BedrockModel.gemma4_26b_a4b`
    - Add `case BedrockModel.gemma4_e2b.id: self = BedrockModel.gemma4_e2b`
    - Add `case BedrockModel.gemma3_27b_it.id: self = BedrockModel.gemma3_27b_it`
    - Add `case BedrockModel.gemma3_12b_it.id: self = BedrockModel.gemma3_12b_it`
    - Add `case BedrockModel.gemma3_4b_it.id: self = BedrockModel.gemma3_4b_it`
    - _Requirements: 1.5, 1.6, 2.4, 3.4, 4.5, 5.5, 6.5_

- [x] 3. Create Chat Completions request and response types
  - [x] 3.1 Create `Sources/BedrockService/BedrockRuntimeClient/ChatCompletions/ChatCompletionsInput.swift`
    - Define `ChatCompletionsRequestBody` as a `Codable, Sendable` struct with fields: `model` (String), `max_completion_tokens` (Int), `messages` ([ChatCompletionsMessage]), `service_tier` (String), `temperature` (Double?), `top_p` (Double?)
    - Define `ChatCompletionsMessage` struct with `role` (String) and `content` (String)
    - Use snake_case coding keys matching the JSON wire format
    - _Requirements: 10.2, 10.3, 11.2_

  - [x] 3.2 Create `Sources/BedrockService/BedrockRuntimeClient/ChatCompletions/ChatCompletionsOutput.swift`
    - Define `ChatCompletionsOutput` as a public `Sendable` struct with `id`, `text`, `model`, `usage` (ChatCompletionsUsage)
    - Define `ChatCompletionsUsage` with `promptTokens`, `completionTokens`, `totalTokens`
    - Define private `ChatCompletionsRawOutput` Codable struct matching the raw JSON response fields (`id`, `choices`, `created`, `model`, `object`, `usage`)
    - Implement conversion from `ChatCompletionsRawOutput` to `ChatCompletionsOutput` that throws `completionNotFound` if `choices` is empty
    - _Requirements: 12.1, 12.2, 12.3, 12.4_

- [x] 4. Implement the `completeChatCompletion` service method
  - [x] 4.1 Create `Sources/BedrockService/BedrockRuntimeClient/ChatCompletions/BedrockService+ChatCompletions.swift`
    - Implement `public func completeChatCompletion(_:with:maxTokens:temperature:topP:serviceTier:authentication:mantleClient:) async throws -> ChatCompletionsOutput`
    - Call `model.getChatCompletionsModality()` to get the modality (throws `invalidModality` if not supported)
    - Validate: both topP and temperature non-nil → throw `notSupported`
    - Validate parameter ranges via `TextGenerationParameters`
    - Build `ChatCompletionsRequestBody` with model ID, messages, resolved maxTokens, optional temperature/topP, service tier
    - Construct URL: `https://bedrock-mantle.{region}.api.aws` + `modality.getChatCompletionsPath()`
    - Resolve authentication via `resolveMantleAuthentication`
    - Send request via `BedrockMantleClient.sendRequest`
    - Decode `ChatCompletionsRawOutput` and convert to `ChatCompletionsOutput`
    - Follow the same structure as `BedrockService+Responses.swift` and `BedrockService+Messages.swift`
    - _Requirements: 9.5, 9.6, 10.1, 10.4, 10.5, 11.1, 11.3, 11.4, 18.1, 18.2, 18.3_

- [x] 5. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Add mock support and model tests
  - [x] 6.1 Add OpenAI/Gemma 3 InvokeModel support to `MockBedrockRuntimeClient` in `Tests/Mock/MockBedrockRuntimeClient.swift`
    - Add a case in `invokeModel` for Gemma 3's modality name (`"Gemma 3 Text Generation"`) that returns an `OpenAIResponseBody`-compatible JSON response
    - _Requirements: 16.4, 16.5, 20.1, 20.2_

  - [x] 6.2 Create `Tests/Mock/MockBedrockMantleChatCompletionsClient.swift` for Chat Completions mock
    - Implement `BedrockMantleClientProtocol` that parses the `messages` array from the request body
    - Return a well-formed Chat Completions JSON response with predictable content ("Mock completion for: {input}")
    - Support both Gemma 4 and Gemma 3 model IDs
    - Follow the pattern of `MockBedrockMantleClient.swift`
    - _Requirements: 10.1, 11.1, 12.1, 12.2_

  - [x] 6.3 Create `Tests/ChatCompletions/ChatCompletionsModelTests.swift` with model definition and modality tests
    - Test all 6 model IDs and names are correct
    - Test `hasChatCompletionsModality()` returns true for all 6 models
    - Test `hasResponsesModality()` returns true for Gemma 4, false for Gemma 3
    - Test `hasTextModality()` returns false for Gemma 4, true for Gemma 3
    - Test `hasConverseModality()` returns false for Gemma 4, true for Gemma 3
    - Test `hasMessagesModality()` returns false for all 6 models
    - Test `hasImageModality()` returns false for all 6 models
    - Test `getChatCompletionsPath()` returns correct path per generation
    - Test `getResponsesPath()` returns `/openai/v1/responses` for Gemma 4
    - Test `BedrockModel(rawValue:)` resolves all 6 models
    - Test `BedrockModel(rawValue:)` returns nil for unknown IDs
    - Test `getTextModality()` throws for Gemma 4
    - Test `getConverseModality()` throws for Gemma 4
    - Test `getResponsesModality()` throws for Gemma 3
    - Test `getMessagesModality()` throws for all 6 models
    - Test Converse features (textGeneration, vision, systemPrompts) for Gemma 3
    - _Requirements: 1.1–6.5, 13.1–13.4, 14.1–14.15, 15.1–15.11, 16.1–16.3, 17.1–17.6_

- [x] 7. Add request serialization and response parsing tests
  - [x] 7.1 Create `Tests/ChatCompletions/ChatCompletionsRequestTests.swift`
    - Test `ChatCompletionsRequestBody` encodes `model`, `max_completion_tokens`, `messages`, `service_tier` fields correctly
    - Test default service tier is `"default"` when not specified
    - Test optional `temperature` and `top_p` fields are omitted when nil
    - Test `ChatCompletionsMessage` serialization with `role` and `content`
    - _Requirements: 10.2, 10.3, 11.2_

  - [x] 7.2 Create `Tests/ChatCompletions/ChatCompletionsResponseTests.swift`
    - Test successful decoding of a valid Chat Completions JSON response
    - Test `text` field is extracted from first `choices[0].message.content`
    - Test empty `choices` array throws `completionNotFound`
    - Test invalid JSON throws a decoding error
    - Test `OpenAIResponseBody` decoding for Gemma 3 InvokeModel responses (reused wire format)
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 20.2, 20.3_

- [x] 8. Add service integration tests
  - [x] 8.1 Create `Tests/ChatCompletions/ChatCompletionsServiceTests.swift`
    - Test `completeChatCompletion` with a Gemma 4 model returns correct output
    - Test `completeChatCompletion` with a Gemma 3 model returns correct output
    - Test `completeChatCompletion` throws `invalidModality` for a model without ChatCompletionsModality (e.g., `.nova_micro`)
    - Test `completeChatCompletion` throws `notSupported` when both temperature and topP are provided
    - Test `createResponse` with Gemma 4 model works (Responses API)
    - Test `completeText` with Gemma 3 model via InvokeModel works
    - Test `completeText` with Gemma 3 throws when both temperature and topP provided
    - Test `completeText` with Gemma 3 throws when topK is provided
    - _Requirements: 9.4, 9.5, 9.6, 10.1, 10.4, 11.1, 11.3, 13.5, 16.4, 16.5, 20.4, 20.5_

- [x] 9. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Add property-based tests
  - [x] 10.1 Write property test: Unknown raw values resolve to nil
    - **Property 1: Unknown raw values resolve to nil**
    - Generate 100 random UUID strings, verify all return nil from `BedrockModel(rawValue:)`
    - Tag with `// Feature: gemma4-model-support, Property 1: Unknown raw values resolve to nil`
    - Add to `Tests/ChatCompletions/ChatCompletionsModelTests.swift`
    - **Validates: Requirements 1.6**

  - [x] 10.2 Write property test: Out-of-range parameter values are rejected
    - **Property 2: Out-of-range parameter values are rejected**
    - Generate 100 random out-of-range values for temperature (< 0 or > 2), maxTokens (< 1 or > 8192), topP (< 0 or > 1)
    - Verify parameter validation throws for each Gemma model
    - Tag with `// Feature: gemma4-model-support, Property 2: Out-of-range parameter values are rejected`
    - Add to `Tests/ChatCompletions/ChatCompletionsModelTests.swift`
    - **Validates: Requirements 7.8, 8.8, 9.5**

  - [x] 10.3 Write property test: Chat Completions request serialization contains required fields
    - **Property 3: Chat Completions request serialization contains required fields**
    - Generate 100 random prompts (1–500 chars) with random valid maxTokens [1, 8192]
    - Serialize `ChatCompletionsRequestBody` and verify JSON contains keys `model`, `max_completion_tokens`, `messages`, `service_tier`
    - Tag with `// Feature: gemma4-model-support, Property 3: Request serialization contains required fields`
    - Add to `Tests/ChatCompletions/ChatCompletionsRequestTests.swift`
    - **Validates: Requirements 10.2, 11.2**

  - [x] 10.4 Write property test: Unsupported parameter combinations throw errors
    - **Property 4: Unsupported parameter combinations throw errors**
    - Generate 100 random (temperature, topP) pairs both non-nil, verify throws `notSupported`
    - Generate 100 random non-nil topK values, verify throws `notSupported`
    - Tag with `// Feature: gemma4-model-support, Property 4: Unsupported parameter combinations throw errors`
    - Add to `Tests/ChatCompletions/ChatCompletionsRequestTests.swift`
    - **Validates: Requirements 10.4, 10.5, 11.3, 11.4, 20.4, 20.5**

  - [x] 10.5 Write property test: Chat Completions response parsing preserves content text
    - **Property 5: Chat Completions response parsing preserves content text**
    - Generate 100 random content strings, embed in valid Chat Completions response JSON template
    - Decode into `ChatCompletionsOutput` and verify `output.text == original content`
    - Tag with `// Feature: gemma4-model-support, Property 5: Response parsing preserves content text`
    - Add to `Tests/ChatCompletions/ChatCompletionsResponseTests.swift`
    - **Validates: Requirements 12.1, 12.2**

  - [x] 10.6 Write property test: InvokeModel response parsing preserves content text (Gemma 3)
    - **Property 6: InvokeModel response parsing preserves content text (Gemma 3)**
    - Generate 100 random content strings, embed in OpenAI-format JSON response
    - Decode via `Gemma3Text.getTextResponseBody()` and verify `completion == original content`
    - Tag with `// Feature: gemma4-model-support, Property 6: InvokeModel response parsing preserves content`
    - Add to `Tests/ChatCompletions/ChatCompletionsResponseTests.swift`
    - **Validates: Requirements 16.5, 20.1, 20.2**

- [x] 11. Create end-to-end Gemma 4 example and add to CI
  - [x] 11.1 Create `Examples/google-gemma/Package.swift`
    - Use swift-tools-version 6.0 with macOS 15 / iOS 18 / tvOS 18 platforms
    - Define executable target `GoogleGemma` depending on `BedrockService` and `swift-log`
    - Use local path dependency (`../..`) for development, with commented-out production URL
    - Follow the exact pattern of `Examples/anthropic-messages/Package.swift`

  - [x] 11.2 Create `Examples/google-gemma/Sources/GoogleGemma.swift`
    - Create a `@main struct Main` with a `static func main() async throws`
    - Demonstrate the Chat Completions API via bedrock-mantle using `completeChatCompletion` with `.gemma4_31b`
    - Demonstrate the Responses API via bedrock-mantle using `createResponse` with `.gemma4_31b`
    - Support both API key (`AWS_BEARER_TOKEN_BEDROCK` env var) and SigV4 authentication (prompt user to choose, like `anthropic-messages` example)
    - Use region `.useast1`
    - Print the prompt, response text, and usage information
    - Include doc comments explaining Gemma 4 is mantle-only (no InvokeModel/Converse)
    - Follow the code style and structure of `Examples/anthropic-messages/Sources/Messages.swift`

  - [x] 11.3 Add `'google-gemma'` to the examples list in `.github/workflows/pull_request.yml`
    - Add `'google-gemma'` to the JSON array in the `examples:` parameter of the integration tests job
    - This ensures the example compiles in CI (CI runs `swift build` on each example)

- [x] 12. Final checkpoint — Ensure all tests pass and example compiles
  - Ensure all tests pass and `swift build` succeeds in `Examples/google-gemma/`, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The project uses Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`) — not XCTest
- Existing mocks (`MockBedrockMantleClient`, `MockBedrockRuntimeClient`) provide patterns for the new mock
- Gemma 3 InvokeModel wire format reuses `OpenAIRequestBody`/`OpenAIResponseBody` from the existing OpenAI model support
- Run tests with `swift test` (never in parallel with other SPM commands)

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "2.1"] },
    { "id": 2, "tasks": ["2.2", "3.1", "3.2"] },
    { "id": 3, "tasks": ["2.3", "4.1"] },
    { "id": 4, "tasks": ["6.1", "6.2"] },
    { "id": 5, "tasks": ["6.3", "7.1", "7.2"] },
    { "id": 6, "tasks": ["8.1"] },
    { "id": 7, "tasks": ["10.1", "10.2", "10.3", "10.4", "10.5", "10.6"] },
    { "id": 8, "tasks": ["11.1", "11.2", "11.3"] }
  ]
}
```
