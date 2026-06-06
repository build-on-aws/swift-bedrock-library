# Implementation Plan: OpenAI Responses API (GPT 5.5 / 5.4)

## Overview

This plan implements support for OpenAI GPT 5.5 and GPT 5.4 models via the Responses API on the `bedrock-mantle` endpoint. Implementation proceeds from foundational types through HTTP client, service integration, tests, and example app.

## Tasks

- [ ] 1. Add AsyncHTTPClient as a direct dependency
  - [ ] 1.1 Update `Package.swift` to add `async-http-client` package dependency
    - Add `.package(url: "https://github.com/swift-server/async-http-client.git", from: "1.24.0")`
    - Add `.product(name: "AsyncHTTPClient", package: "async-http-client")` to BedrockService target dependencies
    - _Requirements: 4.2_

- [ ] 2. Define ResponsesModality protocol and model types
  - [ ] 2.1 Create `ResponsesModality` protocol
    - Create `Sources/BedrockService/BedrockRuntimeClient/Modalities/ResponsesModality.swift`
    - Define `public protocol ResponsesModality: Modality` with `func getResponsesPath() -> String`
    - _Requirements: 1.1, 1.2_

  - [ ] 2.2 Create `OpenAIResponses` modality struct
    - Create `Sources/BedrockService/Models/OpenAI/OpenAIResponses.swift`
    - Implement `struct OpenAIResponses: ResponsesModality` with stored `responsesPath` property
    - Implement `getName()` returning `"OpenAI Responses"`
    - Implement `getResponsesPath()` returning the stored path
    - _Requirements: 1.3, 1.4_

  - [ ] 2.3 Add model definitions for GPT 5.5 and GPT 5.4
    - Add to `Sources/BedrockService/Models/OpenAI/OpenAIBedrockModels.swift`:
      - `.openai_gpt_5_5` with id `"openai.gpt-5.5"`, modality `OpenAIResponses(responsesPath: "/openai/v1/responses")`
      - `.openai_gpt_5_4` with id `"openai.gpt-5.4"`, modality `OpenAIResponses(responsesPath: "/openai/v1/responses")`
    - _Requirements: 2.1, 2.2, 2.3, 2.6_

  - [ ] 2.5 Add ResponsesModality conformance to existing OpenAIText
    - Modify `Sources/BedrockService/Models/OpenAI/OpenAI.swift`:
      - Add `ResponsesModality` conformance to `OpenAIText` struct
      - Implement `getResponsesPath()` returning `"/v1/responses"`
    - This makes existing `.openai_gpt_oss_20b` and `.openai_gpt_oss_120b` usable via `createResponse()`
    - _Requirements: 2.7, 2.8_

  - [ ] 2.4 Add rawValue lookup and modality checks to BedrockModel
    - Add cases for both models in `init?(rawValue:)` switch in `Sources/BedrockService/Models/BedrockModel.swift`
    - Add `hasResponsesModality() -> Bool` method
    - Add `getResponsesModality() throws -> any ResponsesModality` method
    - _Requirements: 1.5, 2.4, 2.5_

- [ ] 3. Implement authentication and HTTP client
  - [ ] 3.1 Create `BedrockMantleAuthentication` enum
    - Create `Sources/BedrockService/BedrockRuntimeClient/Responses/BedrockMantleAuthentication.swift`
    - Define `.apiKey(String)` and `.sigV4` cases
    - Conform to `Sendable`
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ] 3.2 Create `BedrockMantleClientProtocol`
    - Create `Sources/BedrockService/BedrockRuntimeClient/Responses/BedrockMantleClientProtocol.swift`
    - Define async method signature for sending requests
    - _Requirements: 4.1_

  - [ ] 3.3 Implement `BedrockMantleClient`
    - Create `Sources/BedrockService/BedrockRuntimeClient/Responses/BedrockMantleClient.swift`
    - Use `AsyncHTTPClient.HTTPClient` for POST requests
    - Build URL from region + model path
    - Set `Content-Type: application/json`
    - For `.apiKey`: set `Authorization: Bearer {key}` header
    - For `.sigV4`: sign request using `AwsCommonRuntimeKit.Signer.signRequest()`
    - Handle HTTP error responses (4xx/5xx)
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

- [ ] 4. Define request/response types
  - [ ] 4.1 Create `ResponsesInput`
    - Create `Sources/BedrockService/BedrockRuntimeClient/Responses/ResponsesInput.swift`
    - Define `ResponsesRequestBody` with `model`, `input` (messages array), `store` (optional Bool)
    - Define `ResponsesMessage` with `role` and `content` strings
    - _Requirements: 5.1, 5.2, 5.5_

  - [ ] 4.2 Create `ResponsesOutput`
    - Create `Sources/BedrockService/BedrockRuntimeClient/Responses/ResponsesOutput.swift`
    - Define response struct with `id`, `model`, `output` array, `usage`
    - Implement text extraction helper (navigate output → message → content → text)
    - Define `ResponsesUsage` with `inputTokens`, `outputTokens`
    - _Requirements: 5.3, 5.4, 5.5_

- [ ] 5. Integrate with BedrockService
  - [ ] 5.1 Create `BedrockService+Responses.swift`
    - Create `Sources/BedrockService/BedrockRuntimeClient/Responses/BedrockService+Responses.swift`
    - Implement `createResponse(_:with:authentication:store:) async throws -> ResponsesOutput`
    - Validate model has `ResponsesModality`, throw if not
    - Construct request body, call mantle client, parse response
    - Add trace logging for request/response
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 6. Unit tests
  - [ ] 6.1 Create mock mantle client
    - Create `Tests/Mock/MockBedrockMantleClient.swift`
    - Return canned JSON response for valid requests

  - [ ] 6.2 Model definition tests
    - Create `Tests/Responses/ResponsesModelTests.swift`
    - Verify model IDs, names, modality types
    - Verify `hasResponsesModality()` returns true
    - Verify `hasConverseModality()` returns false
    - Verify `getResponsesPath()` returns correct path
    - _Requirements: 7.1_

  - [ ] 6.3 Request serialization tests
    - Create `Tests/Responses/ResponsesRequestTests.swift`
    - Verify request body encodes to expected JSON
    - _Requirements: 7.2_

  - [ ] 6.4 Response deserialization tests
    - Create `Tests/Responses/ResponsesResponseTests.swift`
    - Verify parsing of sample response JSON
    - Verify text extraction from response
    - _Requirements: 7.3_

  - [ ] 6.5 Service integration tests
    - Create `Tests/Responses/ResponsesServiceTests.swift`
    - End-to-end with mock client
    - Test error for model without responses modality
    - _Requirements: 7.4, 7.5, 7.6_

- [ ] 7. Example application
  - [ ] 7.1 Create example package
    - Create `Examples/responses/Package.swift` following existing example pattern
    - Create `Examples/responses/Sources/Responses.swift`
    - Demonstrate calling GPT 5.5 with API key auth
    - Print text response
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 8. Verification
  - [ ] 8.1 Run `swift build` — must pass
  - [ ] 8.2 Run `swift test` — all tests must pass
  - [ ] 8.3 Run `swift build` in `Examples/responses/` — must compile
