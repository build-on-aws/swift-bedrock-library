# Requirements Document

## Introduction

Add support for Claude Mythos 5 (`anthropic.claude-mythos-5`) to the Swift Bedrock Library. Claude Mythos 5 is a next-generation Anthropic model with a 1M token context window and 128K max output tokens. It is available exclusively via the Messages API on the bedrock-mantle endpoint in us-east-1. Unlike Claude Fable 5, Mythos 5 does not support the Converse API, does not support cross-region inference, and has strict sampling constraints (temperature fixed at 1.0, topP restricted to [0.99, 1.0), topK not supported). Reasoning is always enabled and cannot be disabled.

## Glossary

- **Bedrock_Mantle**: The cross-model inference endpoint (`bedrock-mantle.{region}.api.aws`) used by models exposing provider-specific APIs (Anthropic Messages, OpenAI Responses/Chat Completions)
- **Messages_API**: The Anthropic Messages API endpoint for text generation via bedrock-mantle, accessed at path `/anthropic/v1/messages`
- **Converse_API**: The AWS Bedrock Converse API on bedrock-runtime; Claude Mythos 5 does not support this API
- **Claude_Mythos_v5**: The modality struct for Claude Mythos 5, conforming only to TextModality and MessagesModality
- **TextModality**: A protocol for models supporting text generation parameter access and request body building
- **MessagesModality**: A protocol for models supporting the Anthropic Messages API on bedrock-mantle
- **ConverseModality**: A protocol for models supporting the Converse API on bedrock-runtime
- **GlobalCrossRegionInferenceModality**: A protocol enabling cross-region inference with a `global.` prefix; Claude Mythos 5 does not conform to this protocol
- **BedrockModel**: The central type in the Swift Bedrock Library representing a model with its ID, name, and modality configuration
- **AnthropicText**: An existing internal struct that handles Anthropic request/response body serialization
- **Parameter**: A type representing a model parameter with min, max, and default values or a not-supported marker
- **TextGenerationParameters**: A struct aggregating all text generation parameters (temperature, maxTokens, topP, topK, stopSequences, maxPromptSize)
- **ServiceTier**: The Bedrock service tier controlling throughput and pricing

## Requirements

### Requirement 1: Model Definition

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for Claude Mythos 5, so that I can reference it when making Messages API calls.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `claude_mythos_v5` with model ID `"anthropic.claude-mythos-5"`
2. THE BedrockModel `claude_mythos_v5` SHALL have the display name `"Claude Mythos 5"`
3. WHEN the raw value `"anthropic.claude-mythos-5"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `claude_mythos_v5` instance
4. IF a raw value other than any known model ID is provided to `BedrockModel(rawValue:)`, THEN THE BedrockModel initializer SHALL return nil

### Requirement 2: Messages API Support

**User Story:** As a developer, I want Claude Mythos 5 to support the Messages API via bedrock-mantle, so that I can use `createMessage` to interact with the model.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL report `hasMessagesModality()` as true
2. WHEN `getMessagesModality()` is called on `claude_mythos_v5`, THE Library SHALL return a modality whose `getMessagesPath()` returns `"/anthropic/v1/messages"`
3. WHEN `createMessage` is called with `claude_mythos_v5`, THE Library SHALL send the request to `https://bedrock-mantle.us-east-1.api.aws/anthropic/v1/messages`
4. WHEN `createMessage` is called with `claude_mythos_v5`, THE Library SHALL format the request body as a JSON object containing the `model`, `max_tokens`, and `messages` fields using the existing `MessagesRequestBody` format

### Requirement 3: Converse API Exclusion

**User Story:** As a developer, I want clear errors when attempting to use Claude Mythos 5 with the Converse API, so that I understand only the Messages API is available.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL report `hasConverseModality()` as false
2. THE BedrockModel `claude_mythos_v5` SHALL report `hasConverseStreamingModality()` as false
3. IF `getConverseModality()` is called on `claude_mythos_v5`, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error

### Requirement 4: Cross-Region Inference Exclusion

**User Story:** As a developer, I want Claude Mythos 5 to always use its plain model ID without any cross-region prefix, so that requests route correctly to us-east-1.

#### Acceptance Criteria

1. WHEN `getModelIdWithCrossRegionInferencePrefix(region:)` is called on `claude_mythos_v5` with any valid Region value, THE Library SHALL return `"anthropic.claude-mythos-5"` without any prefix
2. THE Claude_Mythos_v5 modality SHALL NOT conform to `GlobalCrossRegionInferenceModality`
3. THE Claude_Mythos_v5 modality SHALL NOT conform to `CrossRegionInferenceModality`

### Requirement 5: Temperature Parameter Constraint

**User Story:** As a developer, I want the temperature parameter for Claude Mythos 5 to be fixed at 1.0, so that invalid temperature values are rejected before reaching the API.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL declare the temperature parameter with minimum value 1, maximum value 1, and default value 1
2. WHEN a temperature value of exactly 1.0 is provided to a Claude Mythos 5 request, THE Library SHALL accept the value
3. IF a temperature value other than 1.0 is provided to a Claude Mythos 5 request, THEN THE Library SHALL reject the value through parameter validation

### Requirement 6: TopP Parameter Constraint

**User Story:** As a developer, I want the topP parameter for Claude Mythos 5 to be restricted to [0.99, 1.0), so that invalid topP values are rejected before reaching the API.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL declare the topP parameter with minimum value 0.99, maximum value 1, and default value nil
2. WHEN a topP value in the range [0.99, 1.0) is provided to a Claude Mythos 5 request, THE Library SHALL accept the value
3. IF a topP value less than 0.99 is provided to a Claude Mythos 5 request, THEN THE Library SHALL reject the value through parameter validation
4. WHEN no topP value is provided (nil), THE Library SHALL omit the parameter from the request body

### Requirement 7: TopK Parameter Exclusion

**User Story:** As a developer, I want topK to be explicitly not supported for Claude Mythos 5, so that invalid parameter usage is caught early.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL declare the topK parameter as `.notSupported`
2. IF a non-nil topK value is provided to `getTextRequestBody()` on Claude Mythos 5, THEN THE Library SHALL handle it according to the existing AnthropicText logic for unsupported parameters

### Requirement 8: Output Token Capacity

**User Story:** As a developer, I want Claude Mythos 5 to support up to 128,000 output tokens, so that I can generate long responses when needed.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL declare the maxTokens parameter with minimum value 1, maximum value 128000, and default value 8192
2. IF a maxTokens value greater than 128000 is provided to a Claude Mythos 5 request, THEN THE Library SHALL reject the value through parameter validation
3. WHEN no maxTokens value is explicitly provided, THE Library SHALL use the default value of 8192

### Requirement 9: Context Window

**User Story:** As a developer, I want the library to declare Claude Mythos 5's 1M token context window, so that prompt size validation is correct.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL declare `maxPromptSize` as 1000000 tokens

### Requirement 10: Reasoning Support

**User Story:** As a developer, I want Claude Mythos 5 to always have reasoning enabled with configurable effort, so that I can control reasoning token budget.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL include `.reasoning` in its supported features list
2. THE BedrockModel `claude_mythos_v5` SHALL declare the maxReasoningTokens parameter with minimum value 1024, maximum value 8191, and default value 4096
3. WHEN a response is received from Claude Mythos 5, THE Library SHALL decode reasoning content (thinking blocks) from the response using the existing MessagesRawOutput format

### Requirement 11: Unsupported Modalities

**User Story:** As a developer, I want clear indication that Claude Mythos 5 does not support image generation, embeddings, or the Responses API, so that I use the correct API path.

#### Acceptance Criteria

1. THE BedrockModel `claude_mythos_v5` SHALL report `hasImageModality()` as false
2. THE BedrockModel `claude_mythos_v5` SHALL report `hasEmbeddingsModality()` as false
3. THE BedrockModel `claude_mythos_v5` SHALL report `hasResponsesModality()` as false
4. THE BedrockModel `claude_mythos_v5` SHALL report `hasTextModality()` as true

### Requirement 12: Mutual Exclusion of Temperature and TopP

**User Story:** As a developer, I want the library to reject requests that provide both temperature and topP simultaneously, so that I avoid ambiguous sampling configurations.

#### Acceptance Criteria

1. IF both topP and temperature are provided (non-nil) for a Claude Mythos 5 request, THEN THE Library SHALL throw a `BedrockLibraryError.notSupported` error indicating that only one of topP or temperature may be provided at a time
