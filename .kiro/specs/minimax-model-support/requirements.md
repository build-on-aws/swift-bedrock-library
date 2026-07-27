# Requirements Document

## Introduction

Add support for MiniMax models to the Swift Bedrock Library. MiniMax models use both the Anthropic Messages API format (at `/anthropic/v1/messages`) and the Chat Completions API format (at `/v1/chat/completions`), routing through the bedrock-mantle endpoint. The implementation introduces a `MiniMax/` provider directory with a `MiniMaxText` modality struct conforming to both `MessagesModality` and `ChatCompletionsModality`, and defines model constants for all three MiniMax variants.

## Glossary

- **Bedrock_Mantle**: The cross-model inference endpoint (`bedrock-mantle.{region}.api.aws`) used by models that expose OpenAI-compatible or Anthropic-compatible APIs
- **MessagesModality**: A protocol for models supporting the Anthropic Messages API on bedrock-mantle, requiring a `getMessagesPath() -> String` method
- **ChatCompletionsModality**: A protocol for models supporting the Chat Completions API on bedrock-mantle, requiring `getChatCompletionsPath() -> String` and `getTextGenerationParameters() -> TextGenerationParameters` methods
- **MiniMax_M2**: MiniMax's M2 model with a 1M token context window and 8K max output tokens
- **MiniMax_M2_1**: MiniMax's M2.1 model with a 196K token context window and 8K max output tokens
- **MiniMax_M2_5**: MiniMax's M2.5 model with a 196K token context window and 8K max output tokens
- **BedrockModel**: The central type in the Swift Bedrock Library representing a model with its ID, name, and modality configuration
- **Modality**: A protocol defining the capabilities of a model (text generation, image, embeddings, responses, messages, chat completions, etc.)
- **createMessage**: The existing `BedrockService` method that handles MessagesModality models — builds the request using `MessagesRequestBody`, sends to bedrock-mantle, and returns `MessagesOutput`
- **completeChatCompletion**: The existing `BedrockService` method that handles ChatCompletionsModality models — builds the request using `ChatCompletionsRequestBody`, sends to bedrock-mantle, and returns `ChatCompletionsOutput`

## Requirements

### Requirement 1: Model Definition for MiniMax M2

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for MiniMax M2, so that I can reference it when making API calls via the Messages API or Chat Completions API.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `minimax_m2` with model ID `"minimax.minimax-m2"`
2. THE BedrockModel `minimax_m2` SHALL have the display name `"MiniMax M2"`
3. THE BedrockModel `minimax_m2` SHALL support MessagesModality with the path `/anthropic/v1/messages`
4. THE BedrockModel `minimax_m2` SHALL support ChatCompletionsModality with the path `/v1/chat/completions`
5. WHEN the raw value `"minimax.minimax-m2"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `minimax_m2` instance
6. IF a raw value other than any known model ID is provided to `BedrockModel(rawValue:)`, THEN THE BedrockModel initializer SHALL return nil

### Requirement 2: Model Definition for MiniMax M2.1

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for MiniMax M2.1, so that I can reference it when making API calls via the Messages API or Chat Completions API.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `minimax_m2_1` with model ID `"minimax.minimax-m2.1"` and display name `"MiniMax M2.1"`
2. THE BedrockModel `minimax_m2_1` SHALL support MessagesModality with the path `/anthropic/v1/messages`
3. THE BedrockModel `minimax_m2_1` SHALL support ChatCompletionsModality with the path `/v1/chat/completions`
4. WHEN the raw value `"minimax.minimax-m2.1"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `minimax_m2_1` instance

### Requirement 3: Model Definition for MiniMax M2.5

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for MiniMax M2.5, so that I can reference it when making API calls via the Messages API or Chat Completions API.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `minimax_m2_5` with model ID `"minimax.minimax-m2.5"` and display name `"MiniMax M2.5"`
2. THE BedrockModel `minimax_m2_5` SHALL support MessagesModality with the path `/anthropic/v1/messages`
3. THE BedrockModel `minimax_m2_5` SHALL support ChatCompletionsModality with the path `/v1/chat/completions`
4. WHEN the raw value `"minimax.minimax-m2.5"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `minimax_m2_5` instance

### Requirement 4: MiniMax Text Generation Parameters

**User Story:** As a developer, I want the MiniMax models to expose appropriate text generation parameters, so that I can control inference behavior when calling `createMessage` or `completeChatCompletion`.

#### Acceptance Criteria

1. ALL MiniMax models SHALL support the temperature parameter with a minimum value of 0, maximum value of 1, and default value of 1
2. ALL MiniMax models SHALL support the maxTokens parameter with a minimum value of 1, maximum value of 8192, and default value of 8192
3. ALL MiniMax models SHALL support the topP parameter with a minimum value of 0, maximum value of 1, and default value of 1
4. ALL MiniMax models SHALL mark the topK parameter as not supported
5. ALL MiniMax models SHALL mark the stopSequences parameter as not supported

### Requirement 5: Unsupported Modalities for MiniMax Models

**User Story:** As a developer, I want clear indication of which APIs MiniMax models support, so that I understand the available capabilities.

#### Acceptance Criteria

1. ALL MiniMax models SHALL report `hasMessagesModality()` as true
2. ALL MiniMax models SHALL report `hasChatCompletionsModality()` as true
3. ALL MiniMax models SHALL report `hasTextModality()` as false
4. ALL MiniMax models SHALL report `hasConverseModality()` as false
5. ALL MiniMax models SHALL report `hasResponsesModality()` as false
6. ALL MiniMax models SHALL report `hasImageModality()` as false
7. IF `getTextModality()` is called on a MiniMax model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error
8. IF `getConverseModality()` is called on a MiniMax model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error
9. IF `getResponsesModality()` is called on a MiniMax model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error

### Requirement 6: MiniMax Messages API Request Routing

**User Story:** As a developer, I want MiniMax model requests to be correctly routed to the bedrock-mantle endpoint using the Anthropic Messages path, so that inference calls reach the correct API.

#### Acceptance Criteria

1. WHEN `createMessage` is called with a MiniMax model, THE Library SHALL send the request to `https://bedrock-mantle.{region}.api.aws/anthropic/v1/messages` where `{region}` is the region configured on the BedrockService instance
2. WHEN `createMessage` is called with a MiniMax model, THE Library SHALL format the request body using the existing `MessagesRequestBody` structure (model ID, maxTokens, messages array)
3. WHEN `createMessage` is called with a MiniMax model, THE Library SHALL support both API key and SigV4 authentication via the `BedrockAuthentication` parameter

### Requirement 7: MiniMax Chat Completions API Request Routing

**User Story:** As a developer, I want MiniMax model requests to be correctly routed to the bedrock-mantle endpoint using the Chat Completions path, so that I can use the OpenAI-compatible API format.

#### Acceptance Criteria

1. WHEN `completeChatCompletion` is called with a MiniMax model, THE Library SHALL send the request to `https://bedrock-mantle.{region}.api.aws/v1/chat/completions` where `{region}` is the region configured on the BedrockService instance
2. WHEN `completeChatCompletion` is called with a MiniMax model, THE Library SHALL format the request body using the existing `ChatCompletionsRequestBody` structure
3. WHEN `completeChatCompletion` is called with a MiniMax model, THE Library SHALL support both API key and SigV4 authentication via the `BedrockAuthentication` parameter

### Requirement 8: No Cross-Region Inference for MiniMax Models

**User Story:** As a developer, I want to understand that MiniMax models only support in-region inference, so that I do not attempt cross-region usage.

#### Acceptance Criteria

1. ALL MiniMax models SHALL NOT conform to `CrossRegionInferenceModality`
2. WHEN `getModelIdWithCrossRegionInferencePrefix(region:)` is called on a MiniMax model, THE method SHALL return the model ID without any prefix

### Requirement 9: Source File Organization

**User Story:** As a contributor to the Swift Bedrock Library, I want MiniMax model source files organized in a dedicated MiniMax directory, so that the codebase remains consistent with the existing model provider structure.

#### Acceptance Criteria

1. THE Library SHALL contain a `Sources/BedrockService/Models/MiniMax/` directory for MiniMax model files
2. THE Library SHALL contain a `MiniMaxBedrockModels.swift` file in the MiniMax directory defining all three model static constants (`minimax_m2`, `minimax_m2_1`, `minimax_m2_5`) as extensions on `BedrockModel`
3. THE Library SHALL contain a `MiniMax.swift` file in the MiniMax directory defining the `MiniMaxText` modality struct conforming to both `MessagesModality` and `ChatCompletionsModality`
4. THE `MiniMax.swift` file SHALL follow the same structural pattern as existing provider modality files (e.g., `xAI.swift`)

### Requirement 10: Messages Example Project

**User Story:** As a developer evaluating the Swift Bedrock Library, I want a working example project demonstrating how to use MiniMax models with `createMessage`, so that I can quickly understand the Messages API integration pattern.

#### Acceptance Criteria

1. THE Library SHALL contain an `Examples/minimax-messages/` directory with a complete executable Swift package
2. THE example SHALL use `BedrockService.createMessage` with a MiniMax model via the bedrock-mantle endpoint
3. THE example SHALL support both API key and SigV4 authentication methods
4. THE example SHALL demonstrate a multi-turn conversation (at least two turns)
5. THE example SHALL follow the same code structure and pattern as `Examples/anthropic-messages/`
6. THE example SHALL be included in the CI integration tests examples list in `.github/workflows/pull_request.yml`

### Requirement 11: Chat Completions Example Project

**User Story:** As a developer evaluating the Swift Bedrock Library, I want a working example project demonstrating how to use MiniMax models with `completeChatCompletion`, so that I can quickly understand the Chat Completions API integration pattern.

#### Acceptance Criteria

1. THE Library SHALL contain an `Examples/minimax-chatcompletions/` directory with a complete executable Swift package
2. THE example SHALL use `BedrockService.completeChatCompletion` with `.minimax_m2` via the bedrock-mantle endpoint
3. THE example SHALL support both API key and SigV4 authentication methods
4. THE example SHALL follow the same code structure and pattern as `Examples/xai-grok/`
5. THE example SHALL be included in the CI integration tests examples list in `.github/workflows/pull_request.yml`
