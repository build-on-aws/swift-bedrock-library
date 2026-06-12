//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Bedrock Library open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Bedrock Library project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Bedrock Library project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import AWSSDKIdentity

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension BedrockService {

    /// Generates a chat completion using the Chat Completions API on the bedrock-mantle endpoint.
    ///
    /// This convenience overload wraps a single user message. For multi-turn conversations,
    /// use the overload that accepts `[ChatCompletionsMessage]`.
    /// - Parameters:
    ///   - input: The user message text
    ///   - model: A BedrockModel that supports ChatCompletionsModality
    ///   - maxTokens: Maximum number of tokens to generate (optional, uses model default if nil)
    ///   - temperature: Optional temperature for sampling (mutually exclusive with topP)
    ///   - topP: Optional top-p for nucleus sampling (mutually exclusive with temperature)
    ///   - serviceTier: The service tier to use (default: .default)
    ///   - authentication: Authentication method — uses the same BedrockAuthentication as the rest of the library.
    ///     For `.apiKey`, the key is sent as a Bearer token. For all other methods (`.default`, `.profile`, `.sso`, etc.),
    ///     credentials are resolved and used for SigV4 signing.
    ///   - mantleClient: Optional custom client for testing
    /// - Returns: A ChatCompletionsOutput containing the model's text reply and usage info
    public func completeChatCompletion(
        _ input: String,
        with model: BedrockModel,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        serviceTier: ServiceTier = .default,
        authentication: BedrockAuthentication,
        mantleClient: BedrockMantleClientProtocol? = nil
    ) async throws -> ChatCompletionsOutput {
        try await completeChatCompletion(
            [ChatCompletionsMessage(role: .user, content: input)],
            with: model,
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP,
            serviceTier: serviceTier,
            authentication: authentication,
            mantleClient: mantleClient
        )
    }

    /// Generates a chat completion using the Chat Completions API on the bedrock-mantle endpoint.
    ///
    /// Use this overload for multi-turn conversations by passing the full message history.
    ///
    /// ```swift
    /// var messages: [ChatCompletionsMessage] = []
    /// messages.append("What is Swift?")
    ///
    /// let reply = try await bedrock.completeChatCompletion(
    ///     messages,
    ///     with: .gemma4_31b,
    ///     authentication: .default
    /// )
    ///
    /// messages.append(reply)
    /// messages.append("How does it compare to Kotlin?")
    ///
    /// let followUp = try await bedrock.completeChatCompletion(
    ///     messages,
    ///     with: .gemma4_31b,
    ///     authentication: .default
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - messages: The conversation messages (alternating user/assistant roles)
    ///   - model: A BedrockModel that supports ChatCompletionsModality
    ///   - maxTokens: Maximum number of tokens to generate (optional, uses model default if nil)
    ///   - temperature: Optional temperature for sampling (mutually exclusive with topP)
    ///   - topP: Optional top-p for nucleus sampling (mutually exclusive with temperature)
    ///   - serviceTier: The service tier to use (default: .default)
    ///   - authentication: Authentication method — uses the same BedrockAuthentication as the rest of the library.
    ///     For `.apiKey`, the key is sent as a Bearer token. For all other methods (`.default`, `.profile`, `.sso`, etc.),
    ///     credentials are resolved and used for SigV4 signing.
    ///   - mantleClient: Optional custom client for testing
    /// - Returns: A ChatCompletionsOutput containing the model's text reply and usage info
    public func completeChatCompletion(
        _ messages: [ChatCompletionsMessage],
        with model: BedrockModel,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        serviceTier: ServiceTier = .default,
        authentication: BedrockAuthentication,
        mantleClient: BedrockMantleClientProtocol? = nil
    ) async throws -> ChatCompletionsOutput {
        let modality = try model.getChatCompletionsModality()
        let parameters = modality.getTextGenerationParameters()

        // Validate: both topP and temperature non-nil → throw notSupported
        if topP != nil && temperature != nil {
            throw BedrockLibraryError.notSupported(
                "Alter either topP or temperature, but not both."
            )
        }

        // Validate parameter ranges
        try parameters.validate(
            maxTokens: maxTokens,
            temperature: temperature,
            topP: topP
        )

        // Resolve maxTokens using model default if not provided
        guard let resolvedMaxTokens = maxTokens ?? parameters.maxTokens.defaultValue else {
            throw BedrockLibraryError.notFound(
                "No value was given for maxTokens and no default value was found"
            )
        }

        let requestBody = ChatCompletionsRequestBody(
            model: model.id,
            max_completion_tokens: resolvedMaxTokens,
            messages: messages,
            service_tier: serviceTier.rawValue,
            temperature: temperature,
            top_p: topP
        )

        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(requestBody)

        let path = modality.getChatCompletionsPath()
        let url = try makeMantleURL(path: path)

        logger.trace(
            "Creating chat completion via bedrock-mantle",
            metadata: [
                "model.id": .string(model.id),
                "url": .string(url.absoluteString),
            ]
        )

        let mantleAuth = try await resolveMantleAuthentication(authentication)

        let client = makeMantleClient(override: mantleClient)
        let responseData = try await client.sendRequest(
            body: bodyData,
            url: url,
            authentication: mantleAuth
        )

        let decoder = JSONDecoder()
        let rawOutput = try decoder.decode(ChatCompletionsRawOutput.self, from: responseData)

        let output = try ChatCompletionsOutput(from: rawOutput)

        logger.trace(
            "Received chat completion from bedrock-mantle",
            metadata: [
                "model.id": .string(model.id),
                "response.id": .string(output.id),
                "usage.promptTokens": .stringConvertible(output.usage.promptTokens),
                "usage.completionTokens": .stringConvertible(output.usage.completionTokens),
            ]
        )

        return output
    }
}
