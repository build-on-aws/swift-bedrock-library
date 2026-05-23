# Implementation Plan: Structured Output

## Overview

This plan implements structured output support for the Swift Bedrock Library, adding JSON schema output format and strict tool use capabilities to the Converse API. Implementation proceeds from foundational types through builder integration, request propagation, tests, documentation, and example app.

## Tasks

- [x] 1. Define foundational types and extend existing types
  - [x] 1.1 Add `structuredOutput` case to `ConverseFeature` enum
    - Add `case structuredOutput = "structured-output"` to `Sources/BedrockService/BedrockRuntimeClient/Modalities/ConverseFeature.swift`
    - Update any model definitions that support structured output to include `.structuredOutput` in their `converseFeatures` array
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 1.2 Create `OutputFormat` struct with initializers and validation
    - Create `Sources/BedrockService/BedrockRuntimeClient/Converse/OutputFormat.swift`
    - Implement `OutputFormat` struct conforming to `Codable` and `Sendable`
    - Store `schema: JSON`, `name: String`, `description: String?`
    - Implement `init(schema: JSON, name: String, description: String?)` with validation: name must match `[a-zA-Z0-9_-]+`, schema must not be `.null`
    - Implement `init(schema: String, name: String, description: String?)` that parses the JSON string
    - Throw `BedrockLibraryError.invalidName` for empty or invalid names
    - Throw `BedrockLibraryError.invalid` for null schema
    - Throw `BedrockLibraryError.decodingError` for invalid JSON strings
    - Use the same name validation regex pattern as `Tool`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 7.1, 7.2, 7.3_

  - [x] 1.3 Implement `OutputFormat.getSDKOutputFormat()` conversion method
    - Add `func getSDKOutputFormat() throws -> BedrockRuntimeClientTypes.OutputFormat`
    - Serialize schema to JSON string via `schema.toJSONString()`
    - Construct `BedrockRuntimeClientTypes.JsonSchemaDefinition` with name, description, and schema string
    - Wrap in `BedrockRuntimeClientTypes.OutputFormatStructure.jsonSchema(...)`
    - Return `BedrockRuntimeClientTypes.OutputFormat(structure:type:)` with type `.jsonSchema`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 1.4 Add `strict` property to `Tool` struct
    - Add `public let strict: Bool` property to `Tool` in `Sources/BedrockService/BedrockRuntimeClient/Converse/Tool.swift`
    - Update `init(name:inputSchema:description:)` to accept `strict: Bool = false` parameter
    - Update `init(from sdkToolSpecification:)` to read `strict` from the SDK type (default to `false` if nil)
    - Update `getSDKToolSpecification()` to pass `strict: true` when enabled, `nil` when false
    - Ensure backward compatibility: existing callers compile without changes
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [x] 2. Integrate structured output into builder and request pipeline
  - [x] 2.1 Extend `ConverseRequestBuilder` with `withOutputFormat` methods
    - Add `public private(set) var outputFormat: OutputFormat?` property to `ConverseRequestBuilder`
    - Implement `public func withOutputFormat(_ outputFormat: OutputFormat) throws -> ConverseRequestBuilder` that validates `.structuredOutput` feature support and stores the format
    - Implement convenience `withOutputFormat(schema: JSON, name: String, description: String?)` that creates an `OutputFormat` and delegates
    - Implement convenience `withOutputFormat(schema: String, name: String, description: String?)` that creates an `OutputFormat` and delegates
    - Update `init(from builder:)` to copy `outputFormat` from the source builder
    - Ensure value semantics: original builder is not mutated
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9_

  - [x] 2.2 Extend `ConverseRequest` to propagate `outputFormat` to SDK input
    - Add `let outputFormat: OutputFormat?` property to `ConverseRequest`
    - Update `ConverseRequest` initializer to accept `outputFormat` parameter
    - Update `getConverseInput(forRegion:)` to include `outputFormat: try outputFormat?.getSDKOutputFormat()` in the `ConverseInput`
    - _Requirements: 5.1, 5.2_

  - [x] 2.3 Extend streaming request to propagate `outputFormat`
    - Update the streaming request construction (ConverseStreamInput) to include `outputFormat: try outputFormat?.getSDKOutputFormat()`
    - Ensure nil propagation when outputFormat is not set
    - _Requirements: 5.3, 5.4_

  - [x] 2.4 Wire `ConverseRequestBuilder` to pass `outputFormat` through to `ConverseRequest`
    - Update `BedrockService.converse(with builder:)` and the streaming equivalent to pass `builder.outputFormat` when constructing `ConverseRequest`
    - Ensure the existing `converse(with model:conversation:...)` path is unaffected (no outputFormat)
    - _Requirements: 4.9, 5.1, 5.2, 5.3, 5.4_

- [x] 3. Checkpoint - Verify compilation and existing tests
  - Ensure `swift build` succeeds and `swift test` passes with all existing tests still green. Ask the user if questions arise.

- [x] 4. Unit tests for structured output
  - [x] 4.1 Write unit tests for `OutputFormat` initialization and validation
    - Create `Tests/Converse/OutputFormatTests.swift`
    - Test successful creation with valid JSON and valid name
    - Test creation with description and without description
    - Test failure for null JSON schema
    - Test failure for invalid JSON string
    - Test failure for empty name
    - Test failure for name with invalid characters (spaces, special chars)
    - Use Swift Testing framework (`@Test`, `#expect`, `#require`)
    - _Requirements: 10.2, 10.3_

  - [x] 4.2 Write unit tests for `OutputFormat.getSDKOutputFormat()`
    - Test that the returned SDK type has `.jsonSchema` type
    - Test that the schema string round-trips correctly
    - Test that name and description are set correctly
    - Test that nil description produces nil in the SDK type
    - _Requirements: 10.4_

  - [x] 4.3 Write unit tests for `Tool` strict parameter
    - Add tests to `Tests/Converse/ConverseToolTests.swift` or create a new file
    - Test `Tool(name:inputSchema:description:strict: true)` stores `strict == true`
    - Test `Tool(name:inputSchema:description:)` without strict defaults to `false`
    - Test `getSDKToolSpecification()` returns `strict: true` when strict is true
    - Test `getSDKToolSpecification()` returns `strict: nil` when strict is false
    - Test backward compatibility: existing initializer compiles and works
    - _Requirements: 10.5, 10.6, 10.7_

  - [x] 4.4 Write unit tests for `ConverseRequestBuilder.withOutputFormat()`
    - Test that `withOutputFormat` stores the format on a supported model
    - Test that `withOutputFormat` throws `BedrockLibraryError.invalidModality` on an unsupported model
    - Test builder immutability: original builder's `outputFormat` remains nil after calling `withOutputFormat`
    - Test `init(from:)` preserves `outputFormat` from source builder
    - Test that multiple `withOutputFormat` calls use the last one
    - _Requirements: 10.8, 10.9, 10.10_

  - [x] 4.5 Write unit tests for `ConverseRequest` output format propagation
    - Test `getConverseInput()` includes `outputFormat` when set
    - Test `getConverseInput()` has nil `outputFormat` when not set
    - Test streaming input includes `outputFormat` when set
    - _Requirements: 10.11_

- [x] 5. Checkpoint - Ensure all tests pass
  - Run `swift test` and ensure all new and existing tests pass. Ask the user if questions arise.

- [x] 6. Property-based tests for correctness properties
  - [x] 6.1 Write property test for backward compatibility (Property 1)
    - **Property 1: Backward Compatibility**
    - For any valid tool name and schema, creating a Tool without the strict parameter results in `strict == false` and `getSDKToolSpecification().strict == nil`
    - **Validates: Requirements 3.2, 3.4, 3.5**

  - [x] 6.2 Write property test for schema preservation (Property 2)
    - **Property 2: Schema Preservation**
    - For any valid JSON schema and valid name, `OutputFormat(schema:name:).getSDKOutputFormat()` produces a JsonSchemaDefinition whose schema string, when parsed back, is semantically equivalent to the original
    - **Validates: Requirements 1.2, 1.3, 2.2**

  - [x] 6.3 Write property test for name validation consistency (Property 3)
    - **Property 3: Name Validation Consistency**
    - For any string, OutputFormat name validation and Tool name validation produce the same accept/reject result
    - **Validates: Requirements 7.1, 7.2**

  - [x] 6.4 Write property test for strict tool mapping (Property 6)
    - **Property 6: Strict Tool Mapping**
    - For any Tool with `strict == true`, `getSDKToolSpecification().strict == true`; for `strict == false`, `.strict == nil`
    - **Validates: Requirements 3.3, 3.4**

  - [x] 6.5 Write property test for immutable builder (Property 7)
    - **Property 7: Immutable Builder**
    - For any builder and valid OutputFormat, calling `withOutputFormat` returns a new builder with the format set, and the original builder remains unchanged
    - **Validates: Requirements 4.6, 4.7**

- [x] 7. Documentation and example application
  - [x] 7.1 Create DocC documentation article for structured output
    - Create `Sources/BedrockService/Docs.docc/StructuredOutput.md`
    - Explain JSON schema output format and strict tool use mechanisms
    - Include code samples for OutputFormat creation (JSON, String variants)
    - Include code samples for Tool with strict parameter
    - Include code samples for ConverseRequestBuilder fluent API with `withOutputFormat`
    - Document best practices for schema design (additionalProperties: false)
    - Explain stop reason handling and when responses may not conform
    - Include a streaming example with structured output
    - Add See Also links to Converse.md, Tools.md, Streaming.md
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9_

  - [x] 7.2 Create example application for structured output
    - Create `Examples/structured-output/` directory with Package.swift, Sources/, and .gitignore
    - Package.swift: depend on swift-bedrock-library via local path, target macOS 15, iOS 18, tvOS 18
    - Implement `@main` struct demonstrating JSON schema output format (schema with 2+ properties, 1+ required)
    - Demonstrate strict tool use (Tool with `strict: true`, detect ToolUseBlock in response)
    - Verify model supports `.structuredOutput` via `hasConverseModality` before making requests
    - Print error and exit if model doesn't support structured output
    - Use do/catch for error handling, print results to stdout
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_

- [x] 8. Final checkpoint - Ensure all tests pass and project builds
  - Run `swift build` and `swift test`. Verify the example compiles with `swift build` in the Examples/structured-output directory. Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The design uses Swift directly, so all implementation tasks use Swift
- The project uses Swift Testing framework (@Test, #expect, #require) — not XCTest

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["1.3", "1.4"] },
    { "id": 2, "tasks": ["2.1"] },
    { "id": 3, "tasks": ["2.2", "2.3"] },
    { "id": 4, "tasks": ["2.4"] },
    { "id": 5, "tasks": ["4.1", "4.2", "4.3"] },
    { "id": 6, "tasks": ["4.4", "4.5"] },
    { "id": 7, "tasks": ["6.1", "6.2", "6.3", "6.4", "6.5"] },
    { "id": 8, "tasks": ["7.1", "7.2"] }
  ]
}
```
