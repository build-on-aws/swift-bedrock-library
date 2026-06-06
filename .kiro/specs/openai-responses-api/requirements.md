# Requirements Document

## Introduction

This document defines the requirements for adding OpenAI GPT 5.5 and GPT 5.4 model support to the Swift Bedrock Library via the Responses API on the `bedrock-mantle` endpoint. These models only support the Responses API — they do not support Invoke, Converse, or Chat Completions. The implementation introduces a new `bedrock-mantle` HTTP client using `AsyncHTTPClient`, a new `ResponsesModality` protocol, and supports both API key and SigV4 authentication.

## Glossary

- **bedrock-mantle**: An AWS endpoint (`bedrock-mantle.{region}.api.aws`) that serves OpenAI-compatible APIs (Responses, Chat Completions, Models) for Amazon Bedrock.
- **Responses API**: OpenAI's stateful conversation API (`POST /v1/responses`) supporting multi-turn interactions, tool use, and conversation history management.
- **ResponsesModality**: A new protocol for models that support the Responses API (as opposed to Converse or Invoke).
- **BedrockMantleClient**: A new HTTP client that communicates with the bedrock-mantle endpoint.
- **BedrockMantleAuthentication**: An enum representing auth modes — API key (Bearer token) or SigV4.
- **AsyncHTTPClient**: The swift-server HTTP client library (already a transitive dependency).
- **SigV4**: AWS Signature Version 4, the standard AWS request signing mechanism.

## Requirements

### Requirement 1: ResponsesModality Protocol

**User Story:** As a developer, I want to identify which models support the Responses API, so I can use the correct API surface.

#### Acceptance Criteria

1. THE `ResponsesModality` protocol SHALL extend `Modality`
2. THE `ResponsesModality` protocol SHALL declare a method `getResponsesPath() -> String` returning the API path for the model
3. Models using path `/openai/v1/responses` (GPT 5.5, GPT 5.4) SHALL return that path
4. Models using path `/v1/responses` (gpt-oss) SHALL return that path
5. `BedrockModel` SHALL provide `hasResponsesModality() -> Bool` and `getResponsesModality() throws -> any ResponsesModality`

### Requirement 2: Model Definitions

**User Story:** As a developer, I want to use `.openai_gpt_5_5` and `.openai_gpt_5_4` model constants, and also use existing gpt-oss models via the Responses API.

#### Acceptance Criteria

1. `BedrockModel.openai_gpt_5_5` SHALL have id `"openai.gpt-5.5"` and name `"OpenAI GPT 5.5"`
2. `BedrockModel.openai_gpt_5_4` SHALL have id `"openai.gpt-5.4"` and name `"OpenAI GPT 5.4"`
3. GPT 5.5 and 5.4 SHALL use `OpenAIResponses` modality with path `/openai/v1/responses`
4. GPT 5.5 and 5.4 SHALL NOT have converse, text, or streaming modality
5. Both new models SHALL be resolvable via `BedrockModel(rawValue:)`
6. Both new models SHALL NOT support cross-region inference
7. Existing `.openai_gpt_oss_20b` and `.openai_gpt_oss_120b` SHALL additionally conform to `ResponsesModality` with path `/v1/responses`
8. Existing gpt-oss models SHALL retain their current Invoke and Converse capabilities unchanged

### Requirement 3: BedrockMantleAuthentication

**User Story:** As a developer, I want to authenticate to the bedrock-mantle endpoint using either an API key or my existing AWS credentials.

#### Acceptance Criteria

1. `BedrockMantleAuthentication` SHALL support `.apiKey(String)` — sets `Authorization: Bearer {key}` header
2. `BedrockMantleAuthentication` SHALL support `.sigV4` — signs the request using AWS credentials via `AwsCommonRuntimeKit.Signer`
3. THE enum SHALL conform to `Sendable`

### Requirement 4: BedrockMantleClient

**User Story:** As a developer, I want the library to handle HTTP communication with the bedrock-mantle endpoint transparently.

#### Acceptance Criteria

1. `BedrockMantleClientProtocol` SHALL define an async method for sending a request and receiving a response
2. `BedrockMantleClient` SHALL use `AsyncHTTPClient` for HTTP POST requests
3. THE client SHALL build the URL as `https://bedrock-mantle.{region}.api.aws{path}` where path comes from the model's `ResponsesModality`
4. THE client SHALL set `Content-Type: application/json` header
5. FOR `.apiKey` auth, THE client SHALL set `Authorization: Bearer {key}` header
6. FOR `.sigV4` auth, THE client SHALL sign the request using `AwsCommonRuntimeKit.Signer.signRequest()` with service `bedrock`
7. THE client SHALL throw appropriate errors for HTTP 4xx/5xx responses
8. THE client SHALL conform to `Sendable`

### Requirement 5: Request/Response Types

**User Story:** As a developer, I want properly typed request and response structures matching the OpenAI Responses API format.

#### Acceptance Criteria

1. THE request body SHALL include `model` (String), `input` (array of messages with role/content), and optional `store` (Bool)
2. Each input message SHALL have a `role` (String: "user", "assistant", "system") and `content` (String)
3. THE response SHALL expose `id` (String), extracted text output, `model` (String), and `usage` (input/output token counts)
4. THE response type SHALL provide a convenience method to extract the text reply
5. All types SHALL conform to `Sendable`

### Requirement 6: BedrockService Integration

**User Story:** As a developer, I want to call `bedrock.createResponse(...)` to invoke models via the Responses API, keeping the single-entry-point pattern.

#### Acceptance Criteria

1. `BedrockService` SHALL expose a public method `createResponse(_:with:authentication:store:) async throws -> ResponsesOutput`
2. THE method SHALL validate that the model has `ResponsesModality`
3. THE method SHALL throw `BedrockLibraryError.invalidModality` if the model does not support Responses
4. THE method SHALL construct the request, call the mantle client, and return the parsed response
5. THE method SHALL log request/response metadata via the service logger

### Requirement 7: Unit Tests

**User Story:** As a developer, I want comprehensive test coverage for the new Responses API surface.

#### Acceptance Criteria

1. Tests SHALL verify model definitions (IDs, modality types, feature checks)
2. Tests SHALL verify request body serialization to correct JSON format
3. Tests SHALL verify response body deserialization from sample JSON
4. Tests SHALL verify end-to-end flow with a mock mantle client
5. Tests SHALL verify error handling for invalid models and failed requests
6. Tests SHALL use Swift Testing framework (`@Test`, `#expect`)

### Requirement 8: Example Application

**User Story:** As a developer, I want a working example showing how to use the Responses API with GPT 5.5.

#### Acceptance Criteria

1. THE example SHALL be in `Examples/responses/`
2. THE example SHALL demonstrate calling GPT 5.5 with an API key
3. THE example SHALL print the model's text response
4. THE example SHALL follow the same Package.swift pattern as other examples
