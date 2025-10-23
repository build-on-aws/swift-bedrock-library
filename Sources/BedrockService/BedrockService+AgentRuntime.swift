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

@preconcurrency import AWSBedrockAgentRuntime
import Logging

extension BedrockService {
    /// Creates a BedrockAgentRuntimeClient
    /// - Parameters:
    ///   - region: The AWS region to configure the client for
    ///   - authentication: The authentication type to use
    ///   - logger: Logger instance
    /// - Returns: Configured BedrockAgentRuntimeProtocol instance
    /// - Throws: Error if client creation fails
    internal static func createBedrockAgentRuntimeClient(
        region: Region,
        authentication: BedrockAuthentication,
        logger: Logging.Logger
    ) async throws -> BedrockAgentRuntimeClient {
        let config: BedrockAgentRuntimeClient.BedrockAgentRuntimeClientConfiguration = try await prepareConfig(
            initialConfig: BedrockAgentRuntimeClient.BedrockAgentRuntimeClientConfiguration(region: region.rawValue),
            authentication: authentication,
            logger: logger
        )
        return BedrockAgentRuntimeClient(config: config)
    }
    /// Retrieves information from a knowledge base
    /// - Parameters:
    ///   - knowledgeBaseId: The unique identifier of the knowledge base to query
    ///   - retrievalQuery: The query to search for in the knowledge base
    ///   - numberOfResults: The number of results to return (optional, defaults to 3)
    /// - Returns: RetrieveResult containing the retrieved results
    /// - Throws: BedrockLibraryError or other errors from the underlying service
    public func retrieve(
        knowledgeBaseId: String,
        retrievalQuery: String,
        numberOfResults: Int = 3
    ) async throws -> RetrieveResult {
        logger.trace(
            "Retrieving from knowledge base",
            metadata: [
                "knowledgeBaseId": .string(knowledgeBaseId),
                "numberOfResults": .stringConvertible(numberOfResults),
            ]
        )

        let input = RetrieveInput(
            knowledgeBaseId: knowledgeBaseId,
            retrievalQuery: BedrockAgentRuntimeClientTypes.KnowledgeBaseQuery(text: retrievalQuery),
            numberOfResults: numberOfResults
        )

        do {
            let response = try await bedrockAgentRuntimeClient.retrieve(input: input)
            logger.trace("Successfully retrieved from knowledge base")
            return RetrieveResult(response)
        } catch {
            try handleCommonError(error, context: "retrieving from knowledge base")
        }
    }
}
