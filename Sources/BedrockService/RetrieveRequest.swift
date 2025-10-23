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

public struct RetrieveRequest: Sendable {
    public let knowledgeBaseId: String
    public let retrievalQuery: String
    public let numberOfResults: Int
    
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
        return RetrieveInput(
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