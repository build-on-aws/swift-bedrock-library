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

        print("Choose authentication method:")
        print("  1. API Key (set AWS_BEARER_TOKEN_BEDROCK environment variable)")
        print("  2. SigV4 (uses default AWS credential provider chain)")
        print()
        print("Enter 1 or 2: ", terminator: "")

        let choice = readLine()?.trimmingCharacters(in: .whitespaces) ?? "1"

        let authentication: BedrockAuthentication
        switch choice {
        case "2":
            print("Using SigV4 with default credential provider chain")
            authentication = .default
        default:
            guard let apiKey = ProcessInfo.processInfo.environment["AWS_BEARER_TOKEN_BEDROCK"] else {
                print("Error: Set AWS_BEARER_TOKEN_BEDROCK environment variable")
                print("Create an API key at: https://console.aws.amazon.com/bedrock/home#/api-keys")
                return
            }
            print("Using API Key authentication")
            authentication = .apiKey(key: apiKey)
        }

        let bedrock = try await BedrockService(
            region: .useast2,
            logger: logger
        )

        let reply = try await bedrock.createResponse(
            "Can you explain the features of Amazon Bedrock?",
            with: .openai_gpt_5_5,
            authentication: authentication,
            store: false
        )

        print("\nModel: \(reply.model.name)")
        print("Response ID: \(reply.id)")
        print("Tokens: \(reply.usage.inputTokens) in / \(reply.usage.outputTokens) out")
        print("\nAssistant: \(reply.text)")
    }
}
