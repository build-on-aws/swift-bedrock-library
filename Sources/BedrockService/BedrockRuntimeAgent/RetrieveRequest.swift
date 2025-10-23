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

/// A request for retrieving information from a knowledge base
public struct RetrieveRequest: Sendable {
    /// The unique identifier of the knowledge base to query
    public let knowledgeBaseId: String
    /// The query text to search for in the knowledge base
    public let retrievalQuery: String
    /// The number of results to return
    public let numberOfResults: Int

    /// Creates a new retrieve request
    /// - Parameters:
    ///   - knowledgeBaseId: The unique identifier of the knowledge base to query
    ///   - retrievalQuery: The query text to search for in the knowledge base
    ///   - numberOfResults: The number of results to return (defaults to 3)
    public init(
        knowledgeBaseId: String,
        retrievalQuery: String,
        numberOfResults: Int = 3
    ) {
        self.knowledgeBaseId = knowledgeBaseId
        self.retrievalQuery = retrievalQuery
        self.numberOfResults = numberOfResults
    }

    internal var input: RetrieveInput {
        RetrieveInput(
            knowledgeBaseId: knowledgeBaseId,
            retrievalConfiguration: BedrockAgentRuntimeClientTypes.KnowledgeBaseRetrievalConfiguration(
                vectorSearchConfiguration: BedrockAgentRuntimeClientTypes.KnowledgeBaseVectorSearchConfiguration(
                    numberOfResults: numberOfResults
                )
            ),
            retrievalQuery: BedrockAgentRuntimeClientTypes.KnowledgeBaseQuery(text: retrievalQuery)
        )
    }
}
