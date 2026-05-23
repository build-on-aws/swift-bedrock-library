# Requirements Document

## Introduction

This document defines the requirements for adding structured output support to the Swift Bedrock Library. Structured output enables developers to constrain model responses to conform to a specified JSON schema, producing reliable machine-readable output. The feature provides two mechanisms: JSON schema output format (via the Converse API's `outputConfig.textFormat`) and strict tool use (via `strict: true` on tool definitions). The feature also includes a demonstration example app and DocC documentation for library consumers.

## Glossary

- **OutputFormat**: A struct representing the structured output configuration, encapsulating a JSON schema, name, and optional description.
- **Tool**: An existing struct representing a tool definition for function calling, extended with a `strict` parameter.
- **ConverseRequestBuilder**: The fluent builder API used to construct Converse API requests.
- **ConverseRequest**: The internal request struct that translates builder configuration into SDK input types.
- **ConverseFeature**: An enum representing capabilities supported by a given Bedrock model (e.g., text generation, vision, tool use, structured output).
- **BedrockModel**: An enum representing available Amazon Bedrock foundation models.
- **JSON**: A library type representing parsed JSON values.
- **BedrockService**: The main service class that executes Converse API calls against Amazon Bedrock.
- **ConverseReply**: The response type returned from a Converse API call.
- **StopReason**: An enum indicating why the model stopped generating (e.g., endTurn, maxTokens, contentFiltered).
- **DocC**: Apple's documentation compiler for generating developer documentation from Swift source code and markdown articles.

## Requirements

### Requirement 1: OutputFormat Type

**User Story:** As a developer, I want to define a JSON schema that constrains model output, so that I can receive guaranteed machine-readable responses conforming to my expected structure.

#### Acceptance Criteria

1. THE OutputFormat struct SHALL store a JSON schema as a JSON value, a name as a String, and an optional description as a String
2. WHEN an OutputFormat is initialized with a JSON value that is not null and a name matching the pattern `[a-zA-Z0-9_-]+`, THE OutputFormat SHALL be created successfully with the schema, name, and description stored
3. WHEN an OutputFormat is initialized with a syntactically valid JSON string and a name matching the pattern `[a-zA-Z0-9_-]+`, THE OutputFormat SHALL parse the string into a JSON value and create the instance successfully
4. IF an OutputFormat is initialized with a null JSON value, THEN THE OutputFormat SHALL throw a BedrockLibraryError.invalid error
5. IF an OutputFormat is initialized with a string that is not syntactically valid JSON, THEN THE OutputFormat SHALL throw a BedrockLibraryError.decodingError
6. IF an OutputFormat is initialized with an empty name, THEN THE OutputFormat SHALL throw a BedrockLibraryError.invalidName error
7. IF an OutputFormat is initialized with a name containing characters outside the pattern `[a-zA-Z0-9_-]+`, THEN THE OutputFormat SHALL throw a BedrockLibraryError.invalidName error
8. THE OutputFormat SHALL conform to Codable and Sendable protocols

### Requirement 2: OutputFormat SDK Conversion

**User Story:** As a developer, I want the OutputFormat to translate correctly into the Bedrock SDK types, so that the API receives the proper structured output configuration.

#### Acceptance Criteria

1. WHEN getSDKOutputFormat() is called on a valid OutputFormat, THE OutputFormat SHALL return a BedrockRuntimeClientTypes.OutputFormat with type set to .jsonSchema and structure set to .jsonSchema containing a JsonSchemaDefinition
2. WHEN getSDKOutputFormat() is called, THE OutputFormat SHALL serialize the schema as a JSON string in the JsonSchemaDefinition such that parsing the string back to JSON produces a value semantically equivalent to the original schema
3. WHEN getSDKOutputFormat() is called, THE OutputFormat SHALL set the name field of the JsonSchemaDefinition to the OutputFormat's name value
4. WHEN getSDKOutputFormat() is called on an OutputFormat with a description, THE OutputFormat SHALL set the description field of the JsonSchemaDefinition to the OutputFormat's description value
5. WHEN getSDKOutputFormat() is called on an OutputFormat without a description, THE OutputFormat SHALL set description to nil in the JsonSchemaDefinition
6. IF the schema cannot be serialized to a JSON string (whether by throwing an error or producing an empty/nil result), THEN THE OutputFormat SHALL throw an error from getSDKOutputFormat()

### Requirement 3: Tool Strict Parameter

**User Story:** As a developer, I want to mark tools as strict, so that the model validates tool input parameters against their schema and guarantees conforming tool calls.

#### Acceptance Criteria

1. THE Tool struct SHALL include a public strict property of type Bool that conforms to Codable and Sendable
2. WHEN a Tool is initialized without specifying the strict parameter, THE Tool SHALL default strict to false
3. WHEN a Tool with strict set to true calls getSDKToolSpecification(), THE Tool SHALL set the strict field to true on the resulting ToolSpecification
4. WHEN a Tool with strict set to false calls getSDKToolSpecification(), THE Tool SHALL set the strict field to nil on the resulting ToolSpecification
5. WHEN existing code uses the Tool initializer without the strict parameter, THE Tool SHALL compile without modification; recompilation of dependent code is acceptable but no source changes SHALL be required
6. WHEN a Tool is initialized from a SDK ToolSpecification that has strict set to true, THE Tool SHALL set its strict property to true
7. WHEN a Tool is initialized from a SDK ToolSpecification that has strict set to nil or false, THE Tool SHALL set its strict property to false

### Requirement 4: ConverseRequestBuilder Structured Output Integration

**User Story:** As a developer, I want to configure structured output through the fluent builder API, so that I can use the same familiar pattern for all Converse API features.

#### Acceptance Criteria

1. THE ConverseRequestBuilder SHALL provide a withOutputFormat method that accepts an OutputFormat instance and returns a new ConverseRequestBuilder
2. THE ConverseRequestBuilder SHALL provide a convenience withOutputFormat method that accepts schema as JSON, name as String, and an optional description as String
3. THE ConverseRequestBuilder SHALL provide a convenience withOutputFormat method that accepts schema as String, name as String, and an optional description as String
4. WHEN withOutputFormat is called on a builder for a model that supports the structuredOutput converse feature, THE ConverseRequestBuilder SHALL create a genuinely new copied builder object whose outputFormat property is set to the provided OutputFormat value
5. IF withOutputFormat is called on a builder for a model that does not support the structuredOutput converse feature, THEN THE ConverseRequestBuilder SHALL throw a BedrockLibraryError.invalidModality error without modifying the original builder
6. WHEN withOutputFormat is called, THE ConverseRequestBuilder SHALL not mutate the original builder instance, leaving its outputFormat property unchanged
7. WHEN a ConverseRequestBuilder is copied via any init(from:) initializer, THE ConverseRequestBuilder SHALL preserve the outputFormat configuration from the source builder
8. WHEN withOutputFormat is called multiple times on the same builder chain, THE ConverseRequestBuilder SHALL use the OutputFormat from the most recent call
9. WHEN a ConverseRequest is built from a ConverseRequestBuilder that has an outputFormat set, THE ConverseRequestBuilder SHALL include the outputFormat in the resulting ConverseInput and ConverseStreamInput passed to the SDK

### Requirement 5: ConverseRequest Output Format Propagation

**User Story:** As a developer, I want the output format to be included in the API request, so that the Bedrock service applies the schema constraint to the model response.

#### Acceptance Criteria

1. WHEN a ConverseRequest has an outputFormat set, THE ConverseRequest SHALL include the result of calling getSDKOutputFormat() on the OutputFormat as the outputFormat parameter of the ConverseInput
2. WHEN a ConverseRequest has no outputFormat set, THE ConverseRequest SHALL set the outputFormat parameter to nil in the ConverseInput
3. WHEN a streaming ConverseRequest has an outputFormat set, THE ConverseRequest SHALL include the result of calling getSDKOutputFormat() on the OutputFormat as the outputFormat parameter of the ConverseStreamInput
4. WHEN a streaming ConverseRequest has no outputFormat set, THE ConverseRequest SHALL set the outputFormat parameter to nil in the ConverseStreamInput

### Requirement 6: ConverseFeature Extension

**User Story:** As a developer, I want to check whether a model supports structured output, so that I can handle unsupported models gracefully.

#### Acceptance Criteria

1. THE ConverseFeature enum SHALL include a structuredOutput case with raw value "structured-output"
2. IF a model's converseFeatures array contains .structuredOutput, THEN THE BedrockModel SHALL return true for hasConverseModality(.structuredOutput)
3. IF a model's converseFeatures array does not contain .structuredOutput, THEN THE BedrockModel SHALL return false for hasConverseModality(.structuredOutput)
4. IF a model does not conform to ConverseModality, THEN THE BedrockModel SHALL return false for hasConverseModality(.structuredOutput)

### Requirement 7: Name Validation Consistency

**User Story:** As a developer, I want consistent naming rules across OutputFormat and Tool, so that I can apply the same naming conventions without confusion.

#### Acceptance Criteria

1. THE OutputFormat name validation SHALL accept only strings matching the pattern [a-zA-Z0-9_-]+ (one or more alphanumeric characters, underscores, or hyphens) using the same matching strategy as Tool name validation
2. IF the OutputFormat name is an empty string, THEN THE OutputFormat initializer SHALL throw a BedrockLibraryError.invalidName error
3. IF the OutputFormat name contains characters outside the set [a-zA-Z0-9_-], THEN THE OutputFormat initializer SHALL throw a BedrockLibraryError.invalidName error

### Requirement 8: Response Handling for Structured Output

**User Story:** As a developer, I want to understand when a structured output response may not conform to the schema, so that I can handle edge cases gracefully.

#### Acceptance Criteria

1. WHEN a model response has stopReason of endTurn and structured output was requested, THE ConverseReply SHALL contain text that is valid JSON conforming to the requested JSON schema structure
2. WHEN a model response has stopReason of maxTokens and structured output was requested, THE ConverseReply SHALL return the response text as-is (even if it is invalid JSON) without throwing an error, and the stopReason SHALL be accessible on the reply so the developer can detect that the output may be truncated and not conform to the schema
3. WHEN a model response has stopReason of contentFiltered or guardrailIntervened and structured output was requested, THE ConverseReply SHALL return the response text as-is without throwing an error, and the stopReason SHALL be accessible on the reply so the developer can detect that the output may not conform to the schema
4. THE ConverseReply SHALL expose the stopReason value from the model response so that the developer can programmatically distinguish between conforming responses (endTurn) and potentially non-conforming responses (maxTokens, contentFiltered, guardrailIntervened)

### Requirement 9: Example Application

**User Story:** As a developer, I want a working example application demonstrating structured output, so that I can quickly understand how to use both JSON schema output format and strict tool use in my own projects.

#### Acceptance Criteria

1. THE Example Application SHALL be located in the Examples/ directory with a lowercase-hyphenated directory name, containing a Package.swift file, a Sources/ directory with a Swift source file using the @main struct pattern, and a .gitignore file
2. THE Example Application SHALL include a Package.swift that depends on the swift-bedrock-library using a local path dependency (`path: "../.."`) and targets macOS 15, iOS 18, and tvOS 18
3. THE Example Application SHALL demonstrate JSON schema output format by defining a JSON schema with at least 2 properties and at least 1 required field, calling `withOutputFormat` on a ConverseRequestBuilder, and printing the returned JSON text response to standard output
4. THE Example Application SHALL demonstrate strict tool use by defining a Tool with `strict` set to `true`, sending a converse request with that tool, detecting the ToolUseBlock in the response, and printing the tool name and input parameters to standard output
5. THE Example Application SHALL use a model that supports the `.structuredOutput` converse feature and SHALL verify support by calling `hasConverseModality` before making requests
6. IF the selected model does not support structured output, THEN THE Example Application SHALL print an error message indicating the model lacks structured output support and exit without calling the Converse API
7. IF an error is thrown during schema creation or API invocation, THEN THE Example Application SHALL catch the error and print it to standard output using a do/catch block
8. THE Example Application SHALL compile without errors using `swift build` and SHALL execute successfully without runtime errors, producing observable printed output for both the JSON schema response and the strict tool use response when run with `swift run`

### Requirement 10: Unit Tests

**User Story:** As a developer, I want comprehensive unit tests covering all new and modified code, so that I can verify correctness and prevent regressions.

#### Acceptance Criteria

1. THE Unit Tests SHALL use the Swift Testing framework (@Test, #expect, #require macros) and be located in the Tests/ directory following the existing test file naming conventions
2. THE Unit Tests SHALL test OutputFormat initialization with valid JSON values and valid names, verifying the stored schema, name, and description
3. THE Unit Tests SHALL test OutputFormat initialization failures for null JSON, invalid JSON strings, empty names, and names with invalid characters
4. THE Unit Tests SHALL test OutputFormat.getSDKOutputFormat() produces a BedrockRuntimeClientTypes.OutputFormat with correct type, structure, schema string, name, and description
5. THE Unit Tests SHALL test Tool initialization with strict set to true and strict set to false, verifying the stored strict value
6. THE Unit Tests SHALL test Tool.getSDKToolSpecification() returns strict as true when Tool.strict is true, and strict as nil when Tool.strict is false
7. THE Unit Tests SHALL test Tool backward compatibility by verifying that Tool(name:inputSchema:description:) without the strict parameter compiles and defaults strict to false
8. THE Unit Tests SHALL test ConverseRequestBuilder.withOutputFormat() stores the output format on a supported model and throws BedrockLibraryError.invalidModality on an unsupported model
9. THE Unit Tests SHALL test ConverseRequestBuilder immutability by verifying that calling withOutputFormat does not mutate the original builder
10. THE Unit Tests SHALL test ConverseRequestBuilder.init(from:) preserves the outputFormat from the source builder
11. THE Unit Tests SHALL test ConverseRequest.getConverseInput() includes outputFormat in the ConverseInput when set and excludes it when nil
12. THE Unit Tests SHALL compile and pass when run with `swift test`

### Requirement 11: DocC Documentation

**User Story:** As a library consumer, I want comprehensive DocC documentation explaining structured output, so that I can learn how to use the feature with code samples and best practices.

#### Acceptance Criteria

1. THE DocC Documentation SHALL be added as a markdown article in the Sources/BedrockService/Docs.docc/ directory
2. THE DocC Documentation SHALL explain both JSON schema output format and strict tool use mechanisms
3. THE DocC Documentation SHALL include code samples showing OutputFormat creation from JSON, String, and Encodable types
4. THE DocC Documentation SHALL include code samples showing Tool creation with strict parameter
5. THE DocC Documentation SHALL include code samples showing the ConverseRequestBuilder fluent API with withOutputFormat
6. THE DocC Documentation SHALL document best practices for schema design including the additionalProperties constraint
7. THE DocC Documentation SHALL explain stop reason handling and when responses may not conform to the schema
8. THE DocC Documentation SHALL include a streaming example with structured output
9. THE DocC Documentation SHALL include See Also links to related documentation articles (Converse, Tools, Streaming)

