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

public struct MockBedrockMantleClient: BedrockMantleClientProtocol {
    public init() {}

    public func sendRequest(
        body: Data,
        url: URL,
        authentication: BedrockMantleAuthentication
    ) async throws -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let model = json["model"] as? String,
            let input = json["input"] as? [[String: Any]],
            let firstMessage = input.first,
            let content = firstMessage["content"] as? String
        else {
            throw BedrockLibraryError.invalidSDKResponse("Invalid request body")
        }

        let response = """
            {
                "id": "resp_mock_123",
                "object": "response",
                "model": "\(model)",
                "output": [
                    {
                        "type": "message",
                        "role": "assistant",
                        "content": [
                            {
                                "type": "output_text",
                                "text": "Mock response for: \(content)"
                            }
                        ]
                    }
                ],
                "usage": {
                    "input_tokens": 10,
                    "output_tokens": 20,
                    "total_tokens": 30
                }
            }
            """
        return response.data(using: .utf8)!
    }
}
