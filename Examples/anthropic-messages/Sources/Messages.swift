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
            try await Main.messages()
        } catch {
            print("Error:\n\(error)")
        }
    }

    /// Demonstrates the Anthropic Messages API via the bedrock-mantle endpoint.
    /// This uses Claude Fable 5 with the /anthropic/v1/messages path.
    ///
    /// Prerequisites:
    /// - You must opt-in to provider data sharing before using Fable 5:
    ///   curl -X PUT https://bedrock-mantle.us-east-1.api.aws/v1/data_retention \
    ///     -H "x-api-key: <your-bedrock-api-key>" \
    ///     -H "Content-Type: application/json" \
    ///     -d '{ "mode": "provider_data_share" }'
    static func messages() async throws {
        var logger = Logger(label: "Messages")
        logger.logLevel = .debug

        print("Anthropic Messages API via bedrock-mantle")
        print("==========================================")
        print()
        print("NOTE: Claude Fable 5 requires a one-time data retention opt-in.")
        print("If you haven't done this yet, run one of:")
        print()
        print("  # With API Key:")
        print("  curl -X PUT https://bedrock-mantle.us-east-1.api.aws/v1/data_retention \\")
        print("    -H \"x-api-key: <your-bedrock-api-key>\" \\")
        print("    -H \"Content-Type: application/json\" \\")
        print("    -d '{ \"mode\": \"provider_data_share\" }'")
        print()
        print("  # With SigV4 (IAM credentials):")
        print("  eval $(aws configure export-credentials --profile <profile> --format env) && \\")
        print("  curl -X PUT https://bedrock.us-east-1.amazonaws.com/data-retention \\")
        print("    -H \"Content-Type: application/json\" \\")
        print("    -d '{\"mode\":\"provider_data_share\"}' \\")
        print("    --aws-sigv4 \"aws:amz:us-east-1:bedrock\" \\")
        print("    --user \"$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY\" \\")
        print("    -H \"x-amz-security-token: $AWS_SESSION_TOKEN\"")
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
            // authentication = .profile(profileName: "pro")
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

        // Turn 1: initial question
        var conversation: [AnthropicMessage] = []
        conversation.append("Explain quantum computing in two sentences.")

        print("\n--- Turn 1 ---")
        print("User: \(conversation[0].content)")
        print()

        let reply1 = try await bedrock.createMessage(
            conversation,
            with: .claude_fable_v5,
            maxTokens: 1024,
            authentication: authentication
        )

        print("Assistant: \(reply1.text)")
        print("(\(reply1.usage.inputTokens) in / \(reply1.usage.outputTokens) out)")

        // Turn 2: follow-up using conversation history
        conversation.append(reply1)
        conversation.append("Now explain it to a 5 year old in one sentence.")

        print("\n--- Turn 2 ---")
        print("User: \(conversation.last!.content)")
        print()

        let reply2 = try await bedrock.createMessage(
            conversation,
            with: .claude_fable_v5,
            maxTokens: 1024,
            authentication: authentication
        )

        print("Assistant: \(reply2.text)")
        print("(\(reply2.usage.inputTokens) in / \(reply2.usage.outputTokens) out)")
    }
}
