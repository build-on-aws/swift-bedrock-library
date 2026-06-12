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

    /// Creates a message using the Anthropic Messages API on the bedrock-mantle endpoint.
    /// - Parameters:
    ///   - input: The user message text
    ///   - model: A BedrockModel that supports MessagesModality
    ///   - maxTokens: Maximum number of tokens to generate (default: 8192)
    ///   - authentication: Authentication method — uses the same BedrockAuthentication as the rest of the library.
    ///     For `.apiKey`, the key is sent as a Bearer token. For all other methods (`.default`, `.profile`, `.sso`, etc.),
    ///     credentials are resolved and used for SigV4 signing.
    ///   - mantleClient: Optional custom client for testing
    /// - Returns: A MessagesOutput containing the model's text reply and usage info
    public func createMessage(
        _ input: String,
        with model: BedrockModel,
        maxTokens: Int = 8_192,
        authentication: BedrockAuthentication,
        mantleClient: BedrockMantleClientProtocol? = nil
    ) async throws -> MessagesOutput {
        try await createMessage(
            [AnthropicMessage(role: .user, content: input)],
            with: model,
            maxTokens: maxTokens,
            authentication: authentication,
            mantleClient: mantleClient
        )
    }

    /// Creates a message using the Anthropic Messages API on the bedrock-mantle endpoint.
    /// Use this overload for multi-turn conversations by passing the full message history.
    /// - Parameters:
    ///   - messages: The conversation messages (alternating user/assistant roles)
    ///   - model: A BedrockModel that supports MessagesModality
    ///   - maxTokens: Maximum number of tokens to generate (default: 8192)
    ///   - authentication: Authentication method — uses the same BedrockAuthentication as the rest of the library.
    ///     For `.apiKey`, the key is sent as a Bearer token. For all other methods (`.default`, `.profile`, `.sso`, etc.),
    ///     credentials are resolved and used for SigV4 signing.
    ///   - mantleClient: Optional custom client for testing
    /// - Returns: A MessagesOutput containing the model's text reply and usage info
    public func createMessage(
        _ messages: [AnthropicMessage],
        with model: BedrockModel,
        maxTokens: Int = 8_192,
        authentication: BedrockAuthentication,
        mantleClient: BedrockMantleClientProtocol? = nil
    ) async throws -> MessagesOutput {
        let modality = try model.getMessagesModality()
        let path = modality.getMessagesPath()

        let requestBody = MessagesRequestBody(
            model: model,
            maxTokens: maxTokens,
            messages: messages
        )

        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(requestBody)

        let url = try makeMantleURL(path: path)

        logger.trace(
            "Creating message via bedrock-mantle",
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
        let rawOutput = try decoder.decode(MessagesRawOutput.self, from: responseData)

        let output = try MessagesOutput(from: rawOutput)

        logger.trace(
            "Received message from bedrock-mantle",
            metadata: [
                "model.id": .string(model.id),
                "response.id": .string(output.id),
                "usage.inputTokens": .stringConvertible(output.usage.inputTokens),
                "usage.outputTokens": .stringConvertible(output.usage.outputTokens),
            ]
        )

        return output
    }
}
