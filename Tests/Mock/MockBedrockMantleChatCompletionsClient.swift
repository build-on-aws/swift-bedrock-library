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

import Foundation

@testable import BedrockService

public struct MockBedrockMantleChatCompletionsClient: BedrockMantleClientProtocol {
    public init() {}

    public func sendRequest(
        body: Data,
        url: URL,
        authentication: BedrockMantleAuthentication
    ) async throws -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let model = json["model"] as? String,
            let messages = json["messages"] as? [[String: Any]],
            let lastMessage = messages.last,
            let content = lastMessage["content"] as? String
        else {
            throw BedrockLibraryError.invalidSDKResponse("Invalid request body")
        }

        let response = """
            {
                "id": "chatcmpl-mock",
                "choices": [
                    {
                        "finish_reason": "stop",
                        "index": 0,
                        "message": {
                            "content": "Mock completion for: \(content)",
                            "role": "assistant"
                        }
                    }
                ],
                "created": 1234567890,
                "model": "\(model)",
                "object": "chat.completion",
                "usage": {
                    "completion_tokens": 10,
                    "prompt_tokens": 5,
                    "total_tokens": 15
                }
            }
            """
        return response.data(using: .utf8)!
    }
}
