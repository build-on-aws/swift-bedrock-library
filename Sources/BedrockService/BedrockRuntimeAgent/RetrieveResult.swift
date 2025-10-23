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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Type alias for knowledge base retrieval result
public typealias RAGRetrievalResult = BedrockAgentRuntimeClientTypes.KnowledgeBaseRetrievalResult

internal struct SerializableResult: Codable {
    let content: String?
    let score: Double?
    let source: String?
}

/// A wrapper around RetrieveOutput providing convenient access to retrieval results
public struct RetrieveResult: Sendable {
    /// The underlying AWS SDK RetrieveOutput
    public let output: RetrieveOutput

    /// Creates a new RetrieveResult from a RetrieveOutput
    /// - Parameter output: The AWS SDK RetrieveOutput to wrap
    public init(_ output: RetrieveOutput) {
        self.output = output
    }

    /// The retrieval results from the knowledge base query
    public var results: [RAGRetrievalResult]? {
        output.retrievalResults
    }

    /// Returns the retrieval result with the highest relevance score
    /// - Returns: The best matching result, or nil if no results
    public func bestMatch() -> RAGRetrievalResult? {
        output.retrievalResults?.max { ($0.score ?? 0) < ($1.score ?? 0) }
    }

    /// Converts the retrieval results to JSON format for use with language models
    /// - Returns: JSON string representation of the results
    /// - Throws: Error if JSON encoding fails
    public func toJSON() throws -> String {
        guard let results = output.retrievalResults else { return "[]" }

        let serializableResults = results.map { result in
            SerializableResult(
                content: result.content?.text,
                score: result.score,
                source: result.location?.s3Location?.uri
            )
        }

        let jsonData = try JSONEncoder().encode(serializableResults)
        return String(data: jsonData, encoding: .utf8) ?? "[]"
    }
}
