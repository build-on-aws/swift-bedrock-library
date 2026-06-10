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

public struct MockBedrockMantleMessagesClient: BedrockMantleClientProtocol {
    public init() {}

    public func sendRequest(
        body: Data,
        url: URL,
        authentication: BedrockMantleAuthentication
    ) async throws -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let model = json["model"] as? String,
            let messages = json["messages"] as? [[String: Any]],
            let firstMessage = messages.first,
            let content = firstMessage["content"] as? String
        else {
            throw BedrockLibraryError.invalidSDKResponse("Invalid request body")
        }

        let response = """
            {
                "id": "msg_mock_456",
                "type": "message",
                "role": "assistant",
                "model": "\(model)",
                "content": [
                    {
                        "type": "text",
                        "text": "Mock message for: \(content)"
                    }
                ],
                "stop_reason": "end_turn",
                "usage": {
                    "input_tokens": 15,
                    "output_tokens": 25
                }
            }
            """
        return response.data(using: .utf8)!
    }
}
