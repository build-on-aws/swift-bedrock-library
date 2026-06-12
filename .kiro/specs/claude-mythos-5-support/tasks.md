# Implementation Plan: Claude Mythos 5 Model Support

## Overview

Add Claude Mythos 5 (`anthropic.claude-mythos-5`) to the Swift Bedrock Library by creating a `Claude_Mythos_v5` modality struct conforming only to `TextModality` and `MessagesModality` (no Converse, no cross-region), adding the `BedrockModel.claude_mythos_v5` static constant, and wiring it into the `init?(rawValue:)` switch. All changes are modifications to existing files plus a new test file.

## Tasks

- [x] 1. Add Claude_Mythos_v5 modality struct and model constant
  - [x] 1.1 Add `Claude_Mythos_v5` struct to `Sources/BedrockService/Models/Anthropic/AnthropicGlobalModels.swift`
    - Define `Claude_Mythos_v5` conforming to `TextModality` and `MessagesModality` only (no `ConverseModality`, no `ConverseStreamingModality`, no `GlobalCrossRegionInferenceModality`)
    - Include private `anthropicText: AnthropicText` property for delegation
    - Implement `init(parameters:features:maxReasoningTokens:)` matching existing pattern
    - Implement `getName()`, `getParameters()`, `getMessagesPath()` (returns `"/anthropic/v1/messages"`)
    - Implement `getTextRequestBody(prompt:maxTokens:temperature:topP:topK:stopSequences:serviceTier:)` delegating to `anthropicText`
    - Implement `getTextResponseBody(from:)` delegating to `anthropicText`
    - Follow the exact structural pattern of `Claude_Fable_v5` but without Converse or cross-region conformances
    - _Requirements: 2.1, 2.2, 3.1, 3.2, 4.2, 4.3, 11.4_

  - [x] 1.2 Add `BedrockModel.claude_mythos_v5` static constant to `Sources/BedrockService/Models/Anthropic/AnthropicBedrockModels.swift`
    - Add `typealias Claude_Mythos_v5 = Claude_Mythos_v5` (not needed if struct is in same module — skip if unnecessary)
    - Define `public static let claude_mythos_v5: BedrockModel` with id `"anthropic.claude-mythos-5"`, name `"Claude Mythos 5"`
    - Set temperature: `Parameter(.temperature, minValue: 1, maxValue: 1, defaultValue: 1)`
    - Set maxTokens: `Parameter(.maxTokens, minValue: 1, maxValue: 128_000, defaultValue: 8_192)`
    - Set topP: `Parameter(.topP, minValue: 0.99, maxValue: 1, defaultValue: nil)`
    - Set topK: `Parameter.notSupported(.topK)`
    - Set stopSequences: `StopSequenceParams(maxSequences: 8191, defaultValue: [])`
    - Set maxPromptSize: `1_000_000`
    - Set features: `[.textGeneration, .systemPrompts, .document, .vision, .toolUse, .reasoning, .structuredOutput]`
    - Set maxReasoningTokens: `Parameter(.maxReasoningTokens, minValue: 1_024, maxValue: 8_191, defaultValue: 4_096)`
    - _Requirements: 1.1, 1.2, 5.1, 6.1, 7.1, 8.1, 9.1, 10.1, 10.2_

  - [x] 1.3 Add case in `BedrockModel.init?(rawValue:)` in `Sources/BedrockService/Models/BedrockModel.swift`
    - Add `case BedrockModel.claude_mythos_v5.id: self = BedrockModel.claude_mythos_v5` in the `// claude` section of the switch statement, after the `claude_fable_v5` case
    - _Requirements: 1.3, 1.4_

- [x] 2. Checkpoint — Ensure project compiles
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Write unit tests for Claude Mythos 5
  - [x] 3.1 Create `Tests/Messages/MythosModelTests.swift` with model constant and modality tests
    - Test `BedrockModel.claude_mythos_v5.id` == `"anthropic.claude-mythos-5"`
    - Test `BedrockModel.claude_mythos_v5.name` == `"Claude Mythos 5"`
    - Test `hasMessagesModality()` returns `true`
    - Test `hasTextModality()` returns `true`
    - Test `hasConverseModality()` returns `false`
    - Test `hasConverseStreamingModality()` returns `false`
    - Test `hasImageModality()` returns `false`
    - Test `hasEmbeddingsModality()` returns `false`
    - Test `hasResponsesModality()` returns `false`
    - Test `getMessagesModality().getMessagesPath()` returns `"/anthropic/v1/messages"`
    - Test `getConverseModality()` throws `BedrockLibraryError.invalidModality`
    - Test `BedrockModel(rawValue: "anthropic.claude-mythos-5")` returns non-nil with correct id
    - Test `BedrockModel(rawValue: "anthropic.claude-mythos-6")` returns nil
    - Test `getModelIdWithCrossRegionInferencePrefix(region: .useast1)` returns `"anthropic.claude-mythos-5"`
    - Test `getModelIdWithCrossRegionInferencePrefix(region: .euwest1)` returns `"anthropic.claude-mythos-5"` (no prefix for any region)
    - Use Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3, 4.1, 11.1, 11.2, 11.3, 11.4_

  - [x] 3.2 Add parameter validation tests to `Tests/Messages/MythosModelTests.swift`
    - Test temperature parameter: minValue == 1, maxValue == 1, defaultValue == 1
    - Test maxTokens parameter: minValue == 1, maxValue == 128_000, defaultValue == 8_192
    - Test topP parameter: minValue == 0.99, maxValue == 1, defaultValue == nil
    - Test topK parameter: `isSupported` == false
    - Test maxPromptSize == 1_000_000
    - Test features list includes `.reasoning`
    - Test maxReasoningTokens: minValue == 1_024, maxValue == 8_191, defaultValue == 4_096
    - _Requirements: 5.1, 5.2, 6.1, 6.2, 6.3, 6.4, 7.1, 7.2, 8.1, 8.2, 8.3, 9.1, 10.1, 10.2_

- [x] 4. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Write property-based tests for Claude Mythos 5
  - [x] 5.1 Write property test: Cross-region prefix is no-op for all regions
    - **Property 4: No cross-region inference prefix applied**
    - Test with all known `Region` enum cases; verify `getModelIdWithCrossRegionInferencePrefix(region:)` returns `"anthropic.claude-mythos-5"` for every region
    - Tag with `// Feature: claude-mythos-5-support, Property 4: No cross-region inference prefix applied`
    - Add to `Tests/Messages/MythosModelTests.swift`
    - **Validates: Requirements 4.1**

  - [x] 5.2 Write property test: Temperature range enforcement
    - **Property 5: Temperature range enforcement**
    - Generate 100 random Double values outside [1, 1] (i.e., in ranges [0, 0.99] ∪ (1.0, 2.0])
    - Verify parameter validation rejects each value (temperature min == max == 1)
    - Tag with `// Feature: claude-mythos-5-support, Property 5: Temperature range enforcement`
    - Add to `Tests/Messages/MythosModelTests.swift`
    - **Validates: Requirements 5.1, 5.3**

  - [x] 5.3 Write property test: TopP range enforcement
    - **Property 7: TopP range enforcement**
    - Generate 100 random values in [0, 0.989]; verify parameter validation rejects each
    - Generate 100 random values in [0.99, 0.999]; verify parameter validation accepts each
    - Tag with `// Feature: claude-mythos-5-support, Property 7: TopP range enforcement`
    - Add to `Tests/Messages/MythosModelTests.swift`
    - **Validates: Requirements 6.1, 6.2, 6.3**

  - [x] 5.4 Write property test: Unknown raw values resolve to nil
    - **Property 8: Unknown raw values resolve to nil**
    - Generate 100 random UUID strings; verify `BedrockModel(rawValue:)` returns nil for each
    - Tag with `// Feature: claude-mythos-5-support, Property 8: Unknown raw values resolve to nil`
    - Add to `Tests/Messages/MythosModelTests.swift`
    - **Validates: Requirements 1.4**

- [x] 6. Refactor bedrock-mantle URL construction and client resolution (DRY)
  - [x] 6.1 Extract a shared `makeMantleURL(path:)` helper method on `BedrockService`
    - Add a `package` or `internal` method: `func makeMantleURL(path: String) throws -> URL` that constructs `"https://bedrock-mantle.\(region.rawValue).api.aws\(path)"` and validates it with `URL(string:encodingInvalidCharacters:)`, throwing `BedrockLibraryError.invalidURI` on failure
    - Place it in `BedrockService.swift` or a new `BedrockService+Mantle.swift` extension file (whichever is cleaner)

  - [x] 6.2 Extract a shared `makeMantleClient(override:)` helper method on `BedrockService`
    - Add a `package` or `internal` method: `func makeMantleClient(override mantleClient: BedrockMantleClientProtocol?) -> BedrockMantleClientProtocol` that returns `mantleClient ?? BedrockMantleClient(region: region.rawValue, logger: self.logger)`
    - Place it alongside `makeMantleURL`

  - [x] 6.3 Refactor `BedrockService+Messages.swift` to use shared helpers
    - Replace inline URL construction with `try makeMantleURL(path: path)`
    - Replace inline client creation with `makeMantleClient(override: mantleClient)`
    - Verify the file still compiles correctly

  - [x] 6.4 Refactor `BedrockService+Responses.swift` to use shared helpers
    - Replace inline URL construction with `try makeMantleURL(path: path)`
    - Replace inline client creation with `makeMantleClient(override: mantleClient)`
    - Verify the file still compiles correctly

  - [x] 6.5 Refactor `BedrockService+ChatCompletions.swift` to use shared helpers
    - Replace inline URL construction with `try makeMantleURL(path: path)`
    - Replace inline client creation with `makeMantleClient(override: mantleClient)`
    - Verify the file still compiles correctly

- [x] 7. Add example project and CI integration
  - [x] 7.1 Create `Examples/anthropic-mythos-messages/Package.swift`
    - Use `swift-tools-version: 6.0`
    - Set platforms to `[.macOS(.v15), .iOS(.v18), .tvOS(.v18)]`
    - Define executable product named `MythosMessages`
    - Add dependency on local `swift-bedrock-library` (path `"../.."`) and `swift-log` from `"1.5.0"`
    - Add executable target `MythosMessages` depending on `BedrockService` and `Logging`
    - Follow the exact `Package.swift` structure of `Examples/anthropic-messages/`
    - _Requirements: 2.3, 2.4_

  - [x] 7.2 Create `Examples/anthropic-mythos-messages/Sources/MythosMessages.swift`
    - Create a `@main struct Main` with `static func main() async throws`
    - Implement a `messages()` function demonstrating Claude Mythos 5 via bedrock-mantle
    - Include data retention opt-in instructions in print statements (same pattern as anthropic-messages example)
    - Offer authentication choice: API Key (`AWS_BEARER_TOKEN_BEDROCK`) or SigV4
    - Use `BedrockService(region: .useast1)` (Mythos 5 is us-east-1 only)
    - Demonstrate a 2-turn conversation using `bedrock.createMessage(conversation, with: .claude_mythos_v5, ...)`
    - Print assistant replies with token usage
    - Follow the exact code structure/style of `Examples/anthropic-messages/Sources/Messages.swift`
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 7.3 Add `'anthropic-mythos-messages'` to the CI examples list in `.github/workflows/pull_request.yml`
    - In the `integration-tests` job, append `'anthropic-mythos-messages'` to the `examples` JSON array string
    - Maintain alphabetical ordering within the array
    - _Requirements: 2.3_

- [x] 8. Final checkpoint — Ensure all tests pass and example compiles
  - Ensure all tests pass and the new example builds with `swift build` from its directory, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The project uses Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`) — not XCTest
- No new files are created in Sources — only `AnthropicGlobalModels.swift`, `AnthropicBedrockModels.swift`, and `BedrockModel.swift` are modified
- One new test file is created: `Tests/Messages/MythosModelTests.swift`
- Run tests with `swift test` (never in parallel with other SPM commands)
- The `Claude_Mythos_v5` struct reuses `AnthropicText` for request/response serialization, following the same delegation pattern as `Claude_Fable_v5`
- A new example `Examples/anthropic-mythos-messages/` demonstrates the Messages API with Claude Mythos 5, following the same pattern as `Examples/anthropic-messages/`
- The example is added to the CI examples list in `.github/workflows/pull_request.yml` so it's built on every PR

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2"] },
    { "id": 2, "tasks": ["1.3"] },
    { "id": 3, "tasks": ["3.1", "3.2"] },
    { "id": 4, "tasks": ["5.1", "5.2", "5.3", "5.4"] },
    { "id": 5, "tasks": ["6.1", "6.2"] },
    { "id": 6, "tasks": ["6.3", "6.4", "6.5"] },
    { "id": 7, "tasks": ["7.1"] },
    { "id": 8, "tasks": ["7.2", "7.3"] }
  ]
}
```
