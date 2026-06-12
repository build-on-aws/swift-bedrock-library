# Requirements Document

## Introduction

Add support for all six Google Gemma models to the Swift Bedrock Library. This includes three Gemma 4 models (mantle-only) and three Gemma 3 models (supporting both bedrock-runtime and bedrock-mantle). The implementation introduces a new `ChatCompletionsModality` protocol and `completeChatCompletion` method on `BedrockService`, creates a `Google/` provider directory, and defines model constants for all six variants. Gemma 4 models route exclusively through bedrock-mantle, while Gemma 3 models support the existing `InvokeModel`/`Converse` path via bedrock-runtime as well as Chat Completions via bedrock-mantle.

## Glossary

- **Bedrock_Mantle**: The cross-model inference endpoint (`bedrock-mantle.{region}.api.aws`) used by models that expose OpenAI-compatible APIs
- **Bedrock_Runtime**: The standard AWS Bedrock Runtime endpoint used for InvokeModel and Converse API calls
- **Chat_Completions_API**: The OpenAI-compatible chat completions endpoint for text generation via the bedrock-mantle service
- **Responses_API**: The OpenAI-compatible responses endpoint for generating responses with extended features (reasoning content, tool calling)
- **ChatCompletionsModality**: A new protocol for models supporting text generation via the Chat Completions API on bedrock-mantle (analogous to MessagesModality and ResponsesModality)
- **TextModality**: A protocol for models supporting text generation via the InvokeModel API on bedrock-runtime
- **ConverseModality**: A protocol for models supporting the Converse API on bedrock-runtime
- **ResponsesModality**: A protocol for models supporting the OpenAI Responses API on bedrock-mantle
- **MessagesModality**: A protocol for models supporting the Anthropic Messages API on bedrock-mantle
- **Gemma4_31B**: Google's 30.7-billion parameter dense model with built-in reasoning, native function calling, and multimodal input (text/image), 256K token context window
- **Gemma4_26B_A4B**: Google's mixture-of-experts model with 25.2B total / 3.8B active parameters, with reasoning, function calling, and multimodal input (text/image), 256K token context window
- **Gemma4_E2B**: Google's compact PLE model with 5.1B total / 2.3B effective parameters, low-latency, reasoning, function calling, multimodal (text/image/audio/video), 128K token context window
- **Gemma3_27B_IT**: Google's largest Gemma 3 model with 27B parameters, instruction-tuned, multimodal (text/image), 128K context, 8K max output
- **Gemma3_12B_IT**: Google's 12B parameter Gemma 3 model, instruction-tuned, multimodal (text/image), 128K context, 8K max output
- **Gemma3_4B_IT**: Google's compact 4B parameter Gemma 3 model, instruction-tuned, edge deployment, 128K context, 8K max output
- **BedrockModel**: The central type in the Swift Bedrock Library representing a model with its ID, name, and modality configuration
- **Modality**: A protocol defining the capabilities of a model (text generation, image, embeddings, responses, messages, chat completions, etc.)
- **ServiceTier**: The Bedrock service tier (default, priority, flex) controlling throughput and pricing
- **Mantle_Base_URL_Gemma4**: `https://bedrock-mantle.{region}.api.aws/openai/v1` — the base URL for Gemma 4 models on bedrock-mantle
- **Mantle_Base_URL_Gemma3**: `https://bedrock-mantle.{region}.api.aws/v1` — the base URL for Gemma 3 models on bedrock-mantle (note: `/v1`, not `/openai/v1`)

## Requirements

### Requirement 1: Model Definition for Gemma 4 31B

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for Google Gemma 4 31B, so that I can reference it when making API calls.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `gemma4_31b` with model ID `"google.gemma-4-31b"`
2. THE BedrockModel `gemma4_31b` SHALL have the display name `"Gemma 4 31B"`
3. THE BedrockModel `gemma4_31b` SHALL support ChatCompletionsModality with the path `/openai/v1/chat/completions`
4. THE BedrockModel `gemma4_31b` SHALL support ResponsesModality with the path `/openai/v1/responses`
5. WHEN the raw value `"google.gemma-4-31b"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `gemma4_31b` instance
6. IF a raw value other than any known model ID is provided to `BedrockModel(rawValue:)`, THEN THE BedrockModel initializer SHALL return nil

### Requirement 2: Model Definition for Gemma 4 26B-A4B

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for Google Gemma 4 26B-A4B, so that I can reference it when making API calls.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `gemma4_26b_a4b` with model ID `"google.gemma-4-26b-a4b"` and display name `"Gemma 4 26B-A4B"`
2. THE BedrockModel `gemma4_26b_a4b` SHALL support ChatCompletionsModality with the path `/openai/v1/chat/completions`
3. THE BedrockModel `gemma4_26b_a4b` SHALL support ResponsesModality with the path `/openai/v1/responses`
4. WHEN the raw value `"google.gemma-4-26b-a4b"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `gemma4_26b_a4b` instance

### Requirement 3: Model Definition for Gemma 4 E2B

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for Google Gemma 4 E2B, so that I can reference it when making API calls.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `gemma4_e2b` with model ID `"google.gemma-4-e2b"` and display name `"Gemma 4 E2B"`
2. THE BedrockModel `gemma4_e2b` SHALL support ChatCompletionsModality with the path `/openai/v1/chat/completions`
3. THE BedrockModel `gemma4_e2b` SHALL support ResponsesModality with the path `/openai/v1/responses`
4. WHEN the raw value `"google.gemma-4-e2b"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `gemma4_e2b` instance

### Requirement 4: Model Definition for Gemma 3 27B IT

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for Google Gemma 3 27B IT, so that I can reference it when making API calls via InvokeModel, Converse, or Chat Completions.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `gemma3_27b_it` with model ID `"google.gemma-3-27b-it"` and display name `"Gemma 3 27B IT"`
2. THE BedrockModel `gemma3_27b_it` SHALL support TextModality for InvokeModel via bedrock-runtime
3. THE BedrockModel `gemma3_27b_it` SHALL support ConverseModality for the Converse API via bedrock-runtime
4. THE BedrockModel `gemma3_27b_it` SHALL support ChatCompletionsModality with the path `/v1/chat/completions`
5. WHEN the raw value `"google.gemma-3-27b-it"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `gemma3_27b_it` instance

### Requirement 5: Model Definition for Gemma 3 12B IT

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for Google Gemma 3 12B IT, so that I can reference it when making API calls via InvokeModel, Converse, or Chat Completions.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `gemma3_12b_it` with model ID `"google.gemma-3-12b-it"` and display name `"Gemma 3 12B IT"`
2. THE BedrockModel `gemma3_12b_it` SHALL support TextModality for InvokeModel via bedrock-runtime
3. THE BedrockModel `gemma3_12b_it` SHALL support ConverseModality for the Converse API via bedrock-runtime
4. THE BedrockModel `gemma3_12b_it` SHALL support ChatCompletionsModality with the path `/v1/chat/completions`
5. WHEN the raw value `"google.gemma-3-12b-it"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `gemma3_12b_it` instance

### Requirement 6: Model Definition for Gemma 3 4B IT

**User Story:** As a developer using the Swift Bedrock Library, I want a `BedrockModel` static constant for Google Gemma 3 4B IT, so that I can reference it when making API calls via InvokeModel, Converse, or Chat Completions.

#### Acceptance Criteria

1. THE BedrockModel SHALL expose a public static constant named `gemma3_4b_it` with model ID `"google.gemma-3-4b-it"` and display name `"Gemma 3 4B IT"`
2. THE BedrockModel `gemma3_4b_it` SHALL support TextModality for InvokeModel via bedrock-runtime
3. THE BedrockModel `gemma3_4b_it` SHALL support ConverseModality for the Converse API via bedrock-runtime
4. THE BedrockModel `gemma3_4b_it` SHALL support ChatCompletionsModality with the path `/v1/chat/completions`
5. WHEN the raw value `"google.gemma-3-4b-it"` is provided to `BedrockModel(rawValue:)`, THE BedrockModel initializer SHALL return the `gemma3_4b_it` instance

### Requirement 7: Gemma 4 Text Generation Parameters

**User Story:** As a developer, I want the Gemma 4 models to expose appropriate text generation parameters, so that I can control inference behavior.

#### Acceptance Criteria

1. THE Gemma4_31B model SHALL support the temperature parameter with a minimum value of 0, maximum value of 2, and default value of 1
2. THE Gemma4_31B model SHALL support the maxTokens parameter with a minimum value of 1, maximum value of 8192, and default value of 8192
3. THE Gemma4_31B model SHALL support the topP parameter with a minimum value of 0, maximum value of 1, and default value of 1
4. THE Gemma4_31B model SHALL mark the topK parameter as not supported
5. THE Gemma4_26B_A4B model SHALL support the same temperature, maxTokens, and topP parameter ranges and defaults as Gemma4_31B, and SHALL mark topK as not supported
6. THE Gemma4_E2B model SHALL support the same temperature, maxTokens, and topP parameter ranges and defaults as Gemma4_31B, and SHALL mark topK as not supported
7. THE Gemma4 models SHALL mark the stopSequences parameter as not supported
8. IF a temperature, maxTokens, or topP value outside the supported range is provided to a Gemma4 model, THEN THE Library SHALL throw an error indicating the value is out of range
9. WHEN no temperature, maxTokens, or topP value is provided in a Gemma4 text generation request, THE Library SHALL use the parameter's default value

### Requirement 8: Gemma 3 Text Generation Parameters

**User Story:** As a developer, I want the Gemma 3 models to expose appropriate text generation parameters, so that I can control inference behavior via InvokeModel or Chat Completions.

#### Acceptance Criteria

1. THE Gemma3_27B_IT model SHALL support the temperature parameter with a minimum value of 0, maximum value of 2, and default value of 1
2. THE Gemma3_27B_IT model SHALL support the maxTokens parameter with a minimum value of 1, maximum value of 8192, and default value of 8192
3. THE Gemma3_27B_IT model SHALL support the topP parameter with a minimum value of 0, maximum value of 1, and default value of 1
4. THE Gemma3_27B_IT model SHALL mark the topK parameter as not supported
5. THE Gemma3_12B_IT model SHALL support the same temperature, maxTokens, and topP parameter ranges and defaults as Gemma3_27B_IT, and SHALL mark topK as not supported
6. THE Gemma3_4B_IT model SHALL support the same temperature, maxTokens, and topP parameter ranges and defaults as Gemma3_27B_IT, and SHALL mark topK as not supported
7. THE Gemma3 models SHALL mark the stopSequences parameter as not supported
8. IF a temperature, maxTokens, or topP value outside the supported range is provided to a Gemma3 model, THEN THE Library SHALL throw an error indicating the value is out of range
9. WHEN no temperature, maxTokens, or topP value is provided in a Gemma3 text generation request, THE Library SHALL use the parameter's default value

### Requirement 9: ChatCompletionsModality Protocol and Service Method

**User Story:** As a developer, I want a `ChatCompletionsModality` protocol and a `completeChatCompletion` method on `BedrockService`, so that models using the Chat Completions API on bedrock-mantle have a clean, consistent interface.

#### Acceptance Criteria

1. THE Library SHALL define a `ChatCompletionsModality` protocol extending `Modality` with a `getChatCompletionsPath() -> String` method and a `getTextGenerationParameters() -> TextGenerationParameters` method
2. THE BedrockModel SHALL expose `hasChatCompletionsModality() -> Bool` and `getChatCompletionsModality() throws -> any ChatCompletionsModality` methods
3. WHEN `hasChatCompletionsModality()` is called on a model conforming to ChatCompletionsModality, THE method SHALL return true
4. IF `getChatCompletionsModality()` is called on a model that does not conform to ChatCompletionsModality, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error
5. WHEN `completeChatCompletion` is called, THE Library SHALL validate parameters against the model's declared ranges before sending the request
6. WHEN `completeChatCompletion` is called, THE Library SHALL support both API key and SigV4 authentication via the `BedrockAuthentication` parameter

### Requirement 10: Chat Completions Request Body for Gemma 4 Models

**User Story:** As a developer, I want the Gemma 4 models to format requests using the OpenAI Chat Completions format routed through bedrock-mantle, so that inference requests are correctly structured.

#### Acceptance Criteria

1. WHEN a text generation request is made with a Gemma 4 model via `completeChatCompletion`, THE Library SHALL send the request to `https://bedrock-mantle.{region}.api.aws/openai/v1/chat/completions` where `{region}` is the region configured on the BedrockService instance
2. WHEN a text generation request is made with a Gemma 4 model via `completeChatCompletion`, THE Library SHALL format the request body as a JSON object containing `model` (string), `max_completion_tokens` (integer), `messages` (array of objects each with `role` and `content` string fields), `service_tier` (string), and optionally `temperature` (double) and `top_p` (double) fields
3. WHEN a text generation request is made with a Gemma 4 model and no service tier is specified by the caller, THE Library SHALL include the `service_tier` field in the request body with the value `"default"`
4. IF both topP and temperature are provided (non-nil) for a Gemma 4 model request, THEN THE Library SHALL throw a `notSupported` error indicating that only one of topP or temperature may be altered at a time
5. IF a topK value is provided (non-nil) for a Gemma 4 model request, THEN THE Library SHALL throw a `notSupported` error indicating that topK is not supported

### Requirement 11: Chat Completions Request Body for Gemma 3 Models

**User Story:** As a developer, I want the Gemma 3 models to also support chat completions via bedrock-mantle, so that I have a consistent interface alongside InvokeModel.

#### Acceptance Criteria

1. WHEN a text generation request is made with a Gemma 3 model via `completeChatCompletion`, THE Library SHALL send the request to `https://bedrock-mantle.{region}.api.aws/v1/chat/completions` where `{region}` is the region configured on the BedrockService instance
2. WHEN a text generation request is made with a Gemma 3 model via `completeChatCompletion`, THE Library SHALL format the request body as a JSON object containing `model` (string), `max_completion_tokens` (integer), `messages` (array), `service_tier` (string), and optionally `temperature` (double) and `top_p` (double) fields
3. IF both topP and temperature are provided (non-nil) for a Gemma 3 model chat completions request, THEN THE Library SHALL throw a `notSupported` error indicating that only one of topP or temperature may be altered at a time
4. IF a topK value is provided (non-nil) for a Gemma 3 model chat completions request, THEN THE Library SHALL throw a `notSupported` error indicating that topK is not supported

### Requirement 12: Chat Completions Response Parsing

**User Story:** As a developer, I want responses from Chat Completions to be parsed into a `ChatCompletionsOutput` type, so that I can use them consistently regardless of which Gemma model I use.

#### Acceptance Criteria

1. WHEN a successful response is received from a Gemma model via Chat Completions on bedrock-mantle, THE Library SHALL decode the response JSON body expecting top-level fields `id`, `choices`, `created`, `model`, `object`, and `usage`
2. WHEN a successful response is decoded, THE Library SHALL extract the text string from the first element of the `choices` array's `message.content` field and return it in a `ChatCompletionsOutput` instance
3. IF the decoded response contains an empty `choices` array, THEN THE Library SHALL throw a `BedrockLibraryError.completionNotFound` error with a descriptive message indicating no choices were available
4. IF the response body cannot be decoded as valid JSON conforming to the expected format, THEN THE Library SHALL throw a decoding error

### Requirement 13: Responses API Support for Gemma 4 Models

**User Story:** As a developer, I want the Gemma 4 models to support the OpenAI Responses API, so that I can use the `createResponse` method with extended features like reasoning.

#### Acceptance Criteria

1. THE Gemma4_31B model SHALL report `hasResponsesModality()` as true
2. THE Gemma4_26B_A4B model SHALL report `hasResponsesModality()` as true
3. THE Gemma4_E2B model SHALL report `hasResponsesModality()` as true
4. WHEN `getResponsesModality()` is called on any Gemma 4 model, THE Library SHALL return a modality whose `getResponsesPath()` returns `/openai/v1/responses`
5. WHEN `createResponse` is called with a Gemma 4 model, THE Library SHALL send the request to `https://bedrock-mantle.{region}.api.aws/openai/v1/responses` where `{region}` is the region configured on the BedrockService instance

### Requirement 14: Unsupported Modalities for Gemma 4 Models

**User Story:** As a developer, I want clear errors when attempting to use Gemma 4 models with unsupported API patterns, so that I understand which APIs are available.

#### Acceptance Criteria

1. THE Gemma4_31B model SHALL report `hasTextModality()` as false
2. THE Gemma4_26B_A4B model SHALL report `hasTextModality()` as false
3. THE Gemma4_E2B model SHALL report `hasTextModality()` as false
4. THE Gemma4_31B model SHALL report `hasConverseModality()` as false
5. THE Gemma4_26B_A4B model SHALL report `hasConverseModality()` as false
6. THE Gemma4_E2B model SHALL report `hasConverseModality()` as false
7. THE Gemma4_31B model SHALL report `hasMessagesModality()` as false
8. THE Gemma4_26B_A4B model SHALL report `hasMessagesModality()` as false
9. THE Gemma4_E2B model SHALL report `hasMessagesModality()` as false
10. THE Gemma4_31B model SHALL report `hasImageModality()` as false
11. THE Gemma4_26B_A4B model SHALL report `hasImageModality()` as false
12. THE Gemma4_E2B model SHALL report `hasImageModality()` as false
13. IF `getTextModality()` is called on a Gemma 4 model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error
14. IF `getConverseModality()` is called on a Gemma 4 model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error
15. IF `getMessagesModality()` is called on a Gemma 4 model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error

### Requirement 15: Unsupported Modalities for Gemma 3 Models

**User Story:** As a developer, I want clear indication that Gemma 3 models do not support Responses or Messages APIs, so that I use the correct API paths.

#### Acceptance Criteria

1. THE Gemma3_27B_IT model SHALL report `hasResponsesModality()` as false
2. THE Gemma3_12B_IT model SHALL report `hasResponsesModality()` as false
3. THE Gemma3_4B_IT model SHALL report `hasResponsesModality()` as false
4. THE Gemma3_27B_IT model SHALL report `hasMessagesModality()` as false
5. THE Gemma3_12B_IT model SHALL report `hasMessagesModality()` as false
6. THE Gemma3_4B_IT model SHALL report `hasMessagesModality()` as false
7. THE Gemma3_27B_IT model SHALL report `hasImageModality()` as false
8. THE Gemma3_12B_IT model SHALL report `hasImageModality()` as false
9. THE Gemma3_4B_IT model SHALL report `hasImageModality()` as false
10. IF `getResponsesModality()` is called on a Gemma 3 model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error
11. IF `getMessagesModality()` is called on a Gemma 3 model, THEN THE Library SHALL throw a `BedrockLibraryError.invalidModality` error

### Requirement 16: Gemma 3 InvokeModel Support

**User Story:** As a developer, I want to use Gemma 3 models with the existing `completeText` method via bedrock-runtime InvokeModel, so that I can use them with the standard text generation flow.

#### Acceptance Criteria

1. THE Gemma3_27B_IT model SHALL report `hasTextModality()` as true
2. THE Gemma3_12B_IT model SHALL report `hasTextModality()` as true
3. THE Gemma3_4B_IT model SHALL report `hasTextModality()` as true
4. WHEN `completeText` is called with a Gemma 3 model, THE Library SHALL format the request body for InvokeModel with the appropriate fields and send it via bedrock-runtime
5. WHEN a response is received from InvokeModel for a Gemma 3 model, THE Library SHALL decode the response and return a `TextCompletion` containing the generated text

### Requirement 17: Gemma 3 Converse API Support

**User Story:** As a developer, I want to use Gemma 3 models with the Converse API, so that I can have multi-turn conversations using the standard Converse interface.

#### Acceptance Criteria

1. THE Gemma3_27B_IT model SHALL report `hasConverseModality()` as true
2. THE Gemma3_12B_IT model SHALL report `hasConverseModality()` as true
3. THE Gemma3_4B_IT model SHALL report `hasConverseModality()` as true
4. THE Gemma3_27B_IT model SHALL support the converse features: textGeneration, vision, and systemPrompts
5. THE Gemma3_12B_IT model SHALL support the converse features: textGeneration, vision, and systemPrompts
6. THE Gemma3_4B_IT model SHALL support the converse features: textGeneration, vision, and systemPrompts

### Requirement 18: Mantle Base URL Routing

**User Story:** As a developer, I want the library to route Gemma 4 and Gemma 3 models to their correct bedrock-mantle base URLs, so that API calls reach the correct endpoint.

#### Acceptance Criteria

1. WHEN `completeChatCompletion` is called with a Gemma 4 model, THE Library SHALL construct the URL using the base `https://bedrock-mantle.{region}.api.aws` concatenated with the model's chat completions path `/openai/v1/chat/completions`
2. WHEN `completeChatCompletion` is called with a Gemma 3 model, THE Library SHALL construct the URL using the base `https://bedrock-mantle.{region}.api.aws` concatenated with the model's chat completions path `/v1/chat/completions`
3. WHEN `createResponse` is called with a Gemma 4 model, THE Library SHALL construct the URL using the base `https://bedrock-mantle.{region}.api.aws` concatenated with the model's responses path `/openai/v1/responses`

### Requirement 19: Source File Organization

**User Story:** As a contributor to the Swift Bedrock Library, I want Google Gemma model source files organized in a dedicated Google directory, so that the codebase remains consistent with the existing model provider structure.

#### Acceptance Criteria

1. THE Library SHALL contain a `Sources/BedrockService/Models/Google/` directory for Google Gemma model files
2. THE Library SHALL contain a `GoogleBedrockModels.swift` file in the Google directory defining all six model static constants (`gemma4_31b`, `gemma4_26b_a4b`, `gemma4_e2b`, `gemma3_27b_it`, `gemma3_12b_it`, `gemma3_4b_it`) as extensions on `BedrockModel`
3. THE Library SHALL contain a `Google.swift` file in the Google directory defining the Gemma 4 modality struct conforming to `ChatCompletionsModality` and `ResponsesModality` protocols
4. THE Library SHALL contain a `Google.swift` file in the Google directory defining the Gemma 3 modality struct conforming to `TextModality`, `ConverseModality`, and `ChatCompletionsModality` protocols
5. THE `Google.swift` file SHALL follow the same structural pattern as existing provider modality files (e.g., `DeepSeek.swift`, `OpenAI.swift`)

### Requirement 20: Gemma 3 InvokeModel Request and Response Format

**User Story:** As a developer, I want the Gemma 3 models to format InvokeModel requests and parse responses correctly, so that text generation works through the bedrock-runtime endpoint.

#### Acceptance Criteria

1. WHEN `completeText` is called with a Gemma 3 model, THE Library SHALL format the request body as a JSON object compatible with the model's expected input schema containing the prompt, max tokens, temperature, and top_p fields
2. WHEN a response is received from InvokeModel for a Gemma 3 model, THE Library SHALL decode the JSON response body and extract the generated text into a `TextCompletion` instance
3. IF the response body cannot be decoded as valid JSON conforming to the expected format, THEN THE Library SHALL throw a decoding error
4. IF both topP and temperature are provided (non-nil) for a Gemma 3 InvokeModel request, THEN THE Library SHALL throw a `notSupported` error indicating that only one of topP or temperature may be altered at a time
5. IF a topK value is provided (non-nil) for a Gemma 3 InvokeModel request, THEN THE Library SHALL throw a `notSupported` error indicating that topK is not supported
