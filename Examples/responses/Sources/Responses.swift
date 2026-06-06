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
import Foundation
import Logging

@main
struct Main {
    static func main() async throws {
        do {
            try await Main.responses()
        } catch {
            print("Error:\n\(error)")
        }
    }

    static func responses() async throws {
        var logger = Logger(label: "Responses")
        logger.logLevel = .debug

        // Set your Bedrock API key here or via environment variable
        guard let apiKey = ProcessInfo.processInfo.environment["AWS_BEARER_TOKEN_BEDROCK"] else {
            print("Error: Set AWS_BEARER_TOKEN_BEDROCK environment variable")
            print("Create an API key at: https://console.aws.amazon.com/bedrock/home#/api-keys")
            return
        }

        let bedrock = try await BedrockService(
            region: .useast2,
            logger: logger
        )

        // GPT 5.5 via the Responses API
        let reply = try await bedrock.createResponse(
            "Can you explain the features of Amazon Bedrock?",
            with: .openai_gpt_5_5,
            authentication: .apiKey(apiKey),
            store: false
        )

        print("Model: \(reply.model.name)")
        print("Response ID: \(reply.id)")
        print("Tokens: \(reply.usage.inputTokens) in / \(reply.usage.outputTokens) out")
        print("\nAssistant: \(reply.text)")
    }
}
