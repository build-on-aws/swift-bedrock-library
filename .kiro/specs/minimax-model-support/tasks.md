# Implementation Plan: MiniMax Model Support

## Overview

Add three MiniMax models to the Swift Bedrock Library by creating a `MiniMax/` provider directory with a `MiniMaxText` modality struct conforming to both `MessagesModality` and `ChatCompletionsModality`, defining model constants, adding `rawValue` resolution, writing tests, and creating two example projects (Messages and Chat Completions). The implementation reuses the existing `createMessage` and `completeChatCompletion` infrastructure — no new protocols or service methods are needed.

## Tasks

- [ ] 1. Create MiniMax provider directory and modality struct
  - [ ] 1.1 Create `Sources/BedrockService/Models/MiniMax/MiniMax.swift` with `MiniMaxText` struct
    - Define `MiniMaxText` conforming to both `MessagesModality` and `ChatCompletionsModality`
    - `getName()` returns `"MiniMax Text Generation"`
    - `getMessagesPath()` returns `"/anthropic/v1/messages"`
    - `getChatCompletionsPath()` returns `"/v1/chat/completions"`
    - `getTextGenerationParameters()` returns `parameters`
    - Store `parameters: TextGenerationParameters` property
    - Include the standard license header and `#if canImport(FoundationEssentials)` import guard
    - Follow the structural pattern of `Sources/BedrockService/Models/xAI/xAI.swift`
    - _Requirements: 9.3, 9.4_

  - [ ] 1.2 Create `Sources/BedrockService/Models/MiniMax/MiniMaxBedrockModels.swift` with three model static constants
    - Define `minimax_m2` (id: `minimax.minimax-m2`, name: `MiniMax M2`, modality: `MiniMaxText`)
    - Define `minimax_m2_1` (id: `minimax.minimax-m2.1`, name: `MiniMax M2.1`, modality: `MiniMaxText`)
    - Define `minimax_m2_5` (id: `minimax.minimax-m2.5`, name: `MiniMax M2.5`, modality: `MiniMaxText`)
    - All models use temperature [0, 1] default 1, maxTokens [1, 8192] default 8192, topP [0, 1] default 1, topK not supported, stopSequences not supported
    - Include the standard license header and `#if canImport(FoundationEssentials)` import guard
    - Follow the pattern of `Sources/BedrockService/Models/xAI/xAIBedrockModels.swift`
    - _Requirements: 1.1–1.4, 2.1–2.3, 3.1–3.3, 4.1–4.5, 9.1, 9.2_

  - [ ] 1.3 Add three new cases to `BedrockModel.init?(rawValue:)` in `Sources/BedrockService/Models/BedrockModel.swift`
    - Add `case BedrockModel.minimax_m2.id: self = BedrockModel.minimax_m2`
    - Add `case BedrockModel.minimax_m2_1.id: self = BedrockModel.minimax_m2_1`
    - Add `case BedrockModel.minimax_m2_5.id: self = BedrockModel.minimax_m2_5`
    - Place them in a `// minimax` section after the `// xai` section and before `// stability`
    - _Requirements: 1.5, 1.6, 2.4, 3.4_

- [ ] 2. Checkpoint — Ensure project builds
  - Run `swift build` to verify the new files compile without errors.

- [ ] 3. Add model tests
  - [ ] 3.1 Create `Tests/Messages/MiniMaxMessagesModelTests.swift` with model definition and modality tests
    - Test all 3 model IDs are correct (`minimax.minimax-m2`, `minimax.minimax-m2.1`, `minimax.minimax-m2.5`)
    - Test all 3 model names are correct (`MiniMax M2`, `MiniMax M2.1`, `MiniMax M2.5`)
    - Test `hasMessagesModality()` returns true for all 3 models
    - Test `hasChatCompletionsModality()` returns true for all 3 models
    - Test `hasTextModality()` returns false for all 3 models
    - Test `hasConverseModality()` returns false for all 3 models
    - Test `hasResponsesModality()` returns false for all 3 models
    - Test `hasImageModality()` returns false for all 3 models
    - Test `getMessagesPath()` returns `/anthropic/v1/messages` for all 3 models
    - Test `getChatCompletionsPath()` returns `/v1/chat/completions` for all 3 models
    - Test `BedrockModel(rawValue:)` resolves all 3 models
    - Test `BedrockModel(rawValue:)` returns nil for unknown IDs
    - Test `getTextModality()` throws for all 3 models
    - Test `getResponsesModality()` throws for all 3 models
    - Test cross-region inference returns plain model ID (no prefix)
    - Use Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`)
    - Follow the pattern of `Tests/Messages/MessagesModelTests.swift`
    - _Requirements: 1.1–3.4, 4.1–4.5, 5.1–5.9, 8.1, 8.2_

  - [ ] 3.2 Create `Tests/Messages/MiniMaxMessagesServiceTests.swift` with service integration tests
    - Test `createMessage` with MiniMax M2 model returns correct output using `MockBedrockMantleMessagesClient`
    - Test `createMessage` with MiniMax M2.5 model returns correct output
    - Test `createMessage` throws `invalidModality` for model without MessagesModality (e.g., `.nova_micro`)
    - Follow the pattern of `Tests/Messages/MessagesServiceTests.swift`
    - _Requirements: 6.1, 6.2, 6.3_

  - [ ] 3.3 Create `Tests/ChatCompletions/MiniMaxChatCompletionsServiceTests.swift` with Chat Completions integration tests
    - Test `completeChatCompletion` with MiniMax M2 model returns correct output using `MockBedrockMantleChatCompletionsClient`
    - Test `completeChatCompletion` with MiniMax M2.5 model returns correct output
    - Test `completeChatCompletion` throws `invalidModality` for model without ChatCompletionsModality
    - Follow the pattern of `Tests/ChatCompletions/ChatCompletionsServiceTests.swift`
    - _Requirements: 7.1, 7.2, 7.3_

- [ ] 4. Checkpoint — Ensure all tests pass
  - Run `swift test` to verify all tests pass.

- [ ] 5. Add property-based tests
  - [ ] 5.1 Write property test: Unknown raw values resolve to nil
    - **Property 1: Unknown raw values resolve to nil**
    - Generate 100 random UUID strings, verify all return nil from `BedrockModel(rawValue:)`
    - Tag with `// Feature: minimax-model-support, Property 1: Unknown raw values resolve to nil`
    - Add to `Tests/Messages/MiniMaxMessagesModelTests.swift`
    - **Validates: Requirements 1.6**

  - [ ] 5.2 Write property test: MiniMax models resolve from rawValue round-trip
    - **Property 2: MiniMax models resolve from rawValue round-trip**
    - Verify all 3 MiniMax model IDs resolve to non-nil instances with matching `id` property
    - Tag with `// Feature: minimax-model-support, Property 2: rawValue round-trip`
    - Add to `Tests/Messages/MiniMaxMessagesModelTests.swift`
    - **Validates: Requirements 1.5, 2.4, 3.4**

  - [ ] 5.3 Write property test: MiniMax models have consistent messages path
    - **Property 3: MiniMax models have consistent messages path**
    - Verify all 3 models return `/anthropic/v1/messages` from `getMessagesModality().getMessagesPath()`
    - Tag with `// Feature: minimax-model-support, Property 3: Consistent messages path`
    - Add to `Tests/Messages/MiniMaxMessagesModelTests.swift`
    - **Validates: Requirements 1.3, 2.2, 3.2, 6.1**

  - [ ] 5.4 Write property test: MiniMax models have consistent chat completions path
    - **Property 4: MiniMax models have consistent chat completions path**
    - Verify all 3 models return `/v1/chat/completions` from `getChatCompletionsModality().getChatCompletionsPath()`
    - Tag with `// Feature: minimax-model-support, Property 4: Consistent chat completions path`
    - Add to `Tests/Messages/MiniMaxMessagesModelTests.swift`
    - **Validates: Requirements 1.4, 2.3, 3.3, 7.1**

  - [ ] 5.5 Write property test: MiniMax models do not have unsupported modalities
    - **Property 5: MiniMax models do not have unsupported modalities**
    - Verify all 4 unsupported modality checks return false for all 3 models (`hasTextModality`, `hasConverseModality`, `hasResponsesModality`, `hasImageModality`)
    - Tag with `// Feature: minimax-model-support, Property 5: No unsupported modalities`
    - Add to `Tests/Messages/MiniMaxMessagesModelTests.swift`
    - **Validates: Requirements 5.3, 5.4, 5.5, 5.6**

  - [ ] 5.6 Write property test: Cross-region inference returns plain model ID
    - **Property 6: Cross-region inference returns plain model ID**
    - Verify all 3 models across multiple regions return the plain model ID without prefix
    - Tag with `// Feature: minimax-model-support, Property 6: Plain model ID for cross-region`
    - Add to `Tests/Messages/MiniMaxMessagesModelTests.swift`
    - **Validates: Requirements 8.1, 8.2**

- [ ] 6. Checkpoint — Ensure all tests pass
  - Run `swift test` to verify all tests pass including property-based tests.

- [ ] 7. Create Messages example project
  - [ ] 7.1 Create `Examples/minimax-messages/Package.swift`
    - Use swift-tools-version 6.0 with macOS 15 / iOS 18 / tvOS 18 platforms
    - Define executable target `MiniMaxMessages` depending on `BedrockService` and `swift-log`
    - Use local path dependency (`../..`) for development, with commented-out production URL
    - Follow the exact pattern of `Examples/anthropic-messages/Package.swift`
    - _Requirements: 10.1_

  - [ ] 7.2 Create `Examples/minimax-messages/Sources/MiniMaxMessages.swift`
    - Create a `@main struct Main` with a `static func main() async throws`
    - Demonstrate the Messages API via bedrock-mantle using `createMessage` with `.minimax_m2`
    - Support both API key (`AWS_BEARER_TOKEN_BEDROCK` env var) and SigV4 authentication
    - Demonstrate a multi-turn conversation (at least 2 turns)
    - Use region `.useast1`
    - Print the prompt, response text, and usage information
    - Include doc comments explaining MiniMax uses the Anthropic Messages path on bedrock-mantle
    - Follow the code style and structure of `Examples/anthropic-messages/Sources/Messages.swift`
    - _Requirements: 10.2, 10.3, 10.4, 10.5_

- [ ] 8. Create Chat Completions example project
  - [ ] 8.1 Create `Examples/minimax-chatcompletions/Package.swift`
    - Use swift-tools-version 6.0 with macOS 15 / iOS 18 / tvOS 18 platforms
    - Define executable target `MiniMaxChatCompletions` depending on `BedrockService` and `swift-log`
    - Use local path dependency (`../..`) for development, with commented-out production URL
    - Follow the exact pattern of `Examples/xai-grok/Package.swift`
    - _Requirements: 11.1_

  - [ ] 8.2 Create `Examples/minimax-chatcompletions/Sources/MiniMaxChatCompletions.swift`
    - Create a `@main struct Main` with a `static func main() async throws`
    - Demonstrate the Chat Completions API via bedrock-mantle using `completeChatCompletion` with `.minimax_m2`
    - Support both API key (`AWS_BEARER_TOKEN_BEDROCK` env var) and SigV4 authentication
    - Use region `.useast1`
    - Print the prompt, response text, and usage information
    - Include doc comments explaining MiniMax supports Chat Completions on bedrock-mantle
    - Follow the code style and structure of `Examples/xai-grok/Sources/Grok.swift`
    - _Requirements: 11.2, 11.3, 11.4_

- [ ] 9. Add both examples to CI
  - [ ] 9.1 Add `'minimax-messages'` and `'minimax-chatcompletions'` to the examples list in `.github/workflows/pull_request.yml`
    - Add both entries to the JSON array in the `examples:` parameter of the integration tests job
    - This ensures both examples compile in CI (CI runs `swift build` on each example)
    - _Requirements: 10.6, 11.5_

- [ ] 10. Final checkpoint — Ensure all tests pass and examples compile
  - Run `swift test` for the library and `swift build` in both `Examples/minimax-messages/` and `Examples/minimax-chatcompletions/` to verify everything works.

## Notes

- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The project uses Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`) — not XCTest
- The existing `MockBedrockMantleMessagesClient` (from `Tests/Mock/`) handles mock responses for `createMessage`
- The existing `MockBedrockMantleChatCompletionsClient` handles mock responses for `completeChatCompletion`
- No new mocks are needed — MiniMax reuses the existing Messages and Chat Completions mock infrastructure
- Run SPM commands (`swift build`, `swift test`) sequentially — never in parallel

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["1.3"] },
    { "id": 2, "tasks": ["3.1", "3.2", "3.3"] },
    { "id": 3, "tasks": ["5.1", "5.2", "5.3", "5.4", "5.5", "5.6"] },
    { "id": 4, "tasks": ["7.1", "7.2", "8.1", "8.2"] },
    { "id": 5, "tasks": ["9.1"] }
  ]
}
```
