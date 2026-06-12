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

/// Demonstrates Google Gemma 4 text generation via the bedrock-mantle endpoint.
///
/// Gemma 4 models are **mantle-only** — they do NOT support InvokeModel or Converse
/// on bedrock-runtime. All requests route through bedrock-mantle using either:
/// - The Chat Completions API (`completeChatCompletion`)
/// - The Responses API (`createResponse`)
///
/// This example shows both API paths with `.gemma4_31b`.
@main
struct Main {
    static func main() async throws {
        do {
            try await Main.gemma()
        } catch {
            print("Error:\n\(error)")
        }
    }

    static func gemma() async throws {
        var logger = Logger(label: "GoogleGemma")
        logger.logLevel = .debug

        print("Google Gemma 4 via bedrock-mantle")
        print("==================================")
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

        // --- Chat Completions API ---
        let chatPrompt = "Explain the difference between a compiler and an interpreter in two sentences."

        print()
        print("--- Chat Completions API ---")
        print("Prompt: \(chatPrompt)")
        print()

        let chatResponse = try await bedrock.completeChatCompletion(
            chatPrompt,
            with: .gemma4_31b,
            authentication: authentication
        )

        print("Response: \(chatResponse.text)")
        print(
            "Usage: \(chatResponse.usage.promptTokens) prompt + \(chatResponse.usage.completionTokens) completion = \(chatResponse.usage.totalTokens) total tokens"
        )

        // --- Responses API ---
        let responsesPrompt = "What are three benefits of open-source software?"

        print()
        print("--- Responses API ---")
        print("Prompt: \(responsesPrompt)")
        print()

        let responsesResponse = try await bedrock.createResponse(
            responsesPrompt,
            with: .gemma4_31b,
            authentication: authentication
        )

        print("Response: \(responsesResponse.text)")
        print("Usage: \(responsesResponse.usage.inputTokens) in / \(responsesResponse.usage.outputTokens) out")
    }
}
