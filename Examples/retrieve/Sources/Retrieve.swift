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

import BedrockService
import Logging

@main
struct Main {
    static func main() async throws {
        do {
            try await Main.retrieve()
        } catch {
            print("Error:\n\(error)")
        }
    }
    
    static func retrieve() async throws {
        var logger = Logger(label: "Retrieve")
        logger.logLevel = .debug

        let bedrock = try await BedrockService(
            region: .uswest2,
            logger: logger
            // uncomment if you use SSO with AWS Identity Center
            // authentication: .sso
        )

        let knowledgeBaseId = "EQ13XRVPLE"
        let query = "should I write open source or open-source"
        let numberOfResults = 3

        print("Retrieving from knowledge base...")
        print("Knowledge Base ID: \(knowledgeBaseId)")
        print("Query: \(query)")
        print("Number of results: \(numberOfResults)")
        print()

        let response = try await bedrock.retrieve(
            knowledgeBaseId: knowledgeBaseId,
            retrievalQuery: query,
            numberOfResults: numberOfResults
        )

        print("Retrieved \(response.results?.count ?? 0) results:")
        
        // Show best match using convenience function
        if let bestMatch = response.bestMatch() {
            print("\n--- Best Match (Score: \(bestMatch.score ?? 0)) ---")
            if let content = bestMatch.content?.text {
                print("Content: \(content)")
            }
        }
        
        // Show all results using convenience property
        // if let results = response.results {
        //     for (index, result) in results.enumerated() {
        //         print("\n--- Result \(index + 1) ---")
        //         if let content = result.content?.text {
        //             print("Content: \(content)")
        //         }
        //         if let score = result.score {
        //             print("Score: \(score)")
        //         }
        //         if let location = result.location?.s3Location {
        //             print("Source: s3://\(location.uri ?? "unknown")")
        //         }
        //     }
        // }
    }
}