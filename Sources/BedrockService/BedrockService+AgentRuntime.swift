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
    /// Retrieves information from a knowledge base for RAG applications
    /// 
    /// This method queries an Amazon Bedrock knowledge base to retrieve relevant information
    /// that can be used for Retrieval-Augmented Generation (RAG) applications.
    /// 
    /// - Parameters:
    ///   - knowledgeBaseId: The unique identifier of the knowledge base to query
    ///   - retrievalQuery: The query to search for in the knowledge base
    ///   - numberOfResults: The number of results to return (optional, defaults to 3)
    /// - Returns: RetrieveResult containing the retrieved results with convenience methods
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

        let request = RetrieveRequest(
            knowledgeBaseId: knowledgeBaseId,
            retrievalQuery: retrievalQuery,
            numberOfResults: numberOfResults
        )

        do {
            let response = try await bedrockAgentRuntimeClient.retrieve(input: request.input)
            logger.trace("Successfully retrieved from knowledge base")
            return RetrieveResult(response)
        } catch {
            try handleCommonError(error, context: "retrieving from knowledge base")
        }
    }
}
