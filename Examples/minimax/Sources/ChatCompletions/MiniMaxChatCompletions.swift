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

/// Demonstrates MiniMax text generation via the OpenAI Chat Completions API on bedrock-mantle.
///
/// MiniMax models support the Chat Completions format at `/v1/chat/completions`.
/// This example shows text generation using `completeChatCompletion`.
@main
struct Main {
    static func main() async throws {
        do {
            try await Main.chatCompletions()
        } catch {
            print("Error:\n\(error)")
        }
    }

    static func chatCompletions() async throws {
        var logger = Logger(label: "MiniMaxChatCompletions")
        logger.logLevel = .debug

        print("MiniMax Chat Completions API via bedrock-mantle")
        print("================================================")
        print()
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
            region: .useast1,
            logger: logger
        )

        let prompt = "Explain the difference between a compiler and an interpreter in two sentences."

        print()
        print("--- Chat Completions API ---")
        print("Prompt: \(prompt)")
        print()

        let response = try await bedrock.completeChatCompletion(
            prompt,
            with: .minimax_m2,
            authentication: authentication
        )

        print("Response: \(response.text)")
        print(
            "Usage: \(response.usage.promptTokens) prompt + \(response.usage.completionTokens) completion = \(response.usage.totalTokens) total tokens"
        )
    }
}
