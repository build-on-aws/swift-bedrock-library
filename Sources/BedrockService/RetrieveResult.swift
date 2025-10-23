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

public typealias RAGRetrievalResult = BedrockAgentRuntimeClientTypes.KnowledgeBaseRetrievalResult

struct SerializableResult: Codable {
    let content: String?
    let score: Double?
    let source: String?
}

public struct RetrieveResult: Sendable {
    public let output: RetrieveOutput

    public init(_ output: RetrieveOutput) {
        self.output = output
    }

    public var results: [RAGRetrievalResult]? {
        output.retrievalResults
    }

    public func bestMatch() -> RAGRetrievalResult? {
        output.retrievalResults?.max { ($0.score ?? 0) < ($1.score ?? 0) }
    }

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
