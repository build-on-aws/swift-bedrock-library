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

    /// Creates a response using the OpenAI Responses API on the bedrock-mantle endpoint.
    /// - Parameters:
    ///   - input: The user message text
    ///   - model: A BedrockModel that supports ResponsesModality
    ///   - authentication: Authentication method — uses the same BedrockAuthentication as the rest of the library.
    ///     For `.apiKey`, the key is sent as a Bearer token. For all other methods (`.default`, `.profile`, `.sso`, etc.),
    ///     credentials are resolved and used for SigV4 signing.
    ///   - store: Whether to store the response for multi-turn conversations (default: nil, uses server default)
    ///   - mantleClient: Optional custom client for testing
    /// - Returns: A ResponsesOutput containing the model's text reply and usage info
    public func createResponse(
        _ input: String,
        with model: BedrockModel,
        authentication: BedrockAuthentication,
        store: Bool? = nil,
        mantleClient: BedrockMantleClientProtocol? = nil
    ) async throws -> ResponsesOutput {
        let modality = try model.getResponsesModality()
        let path = modality.getResponsesPath()

        let requestBody = ResponsesRequestBody(
            model: model,
            input: [ResponsesMessage(role: .user, content: input)],
            store: store
        )

        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(requestBody)

        let url = try makeMantleURL(path: path)

        logger.trace(
            "Creating response via bedrock-mantle",
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
        let rawOutput = try decoder.decode(ResponsesRawOutput.self, from: responseData)

        let output = try ResponsesOutput(from: rawOutput)

        logger.trace(
            "Received response from bedrock-mantle",
            metadata: [
                "model.id": .string(model.id),
                "response.id": .string(output.id),
                "usage.inputTokens": .stringConvertible(output.usage.inputTokens),
                "usage.outputTokens": .stringConvertible(output.usage.outputTokens),
            ]
        )

        return output
    }

    func resolveMantleAuthentication(
        _ authentication: BedrockAuthentication
    ) async throws -> BedrockMantleAuthentication {
        switch authentication {
        case .apiKey(let key):
            return .apiKey(key)
        default:
            guard let resolver = try await authentication.getAWSCredentialIdentityResolver(logger: logger) else {
                return .sigV4(DefaultAWSCredentialIdentityResolverChain())
            }
            return .sigV4(resolver)
        }
    }
}
