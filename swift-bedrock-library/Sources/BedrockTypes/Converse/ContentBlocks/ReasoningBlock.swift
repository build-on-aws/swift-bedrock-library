//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Foundation Models Playground open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Foundation Models Playground project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Foundation Models Playground project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@preconcurrency import AWSBedrockRuntime
import Foundation

public struct EncryptedReasoning: Codable, Sendable {
    public var reasoning: Data

    public var description: String {
        "Encrypted reasoning: \(reasoning)"
    }

    public init(_ data: Data) {
        self.reasoning = data
    }

    public func getSDKReasoningBlock() -> BedrockRuntimeClientTypes.ReasoningContentBlock {
        .redactedcontent(reasoning)
    }
}

public struct Reasoning: Codable, CustomStringConvertible, Sendable {
    public var signature: String?
    public var reasoning: String

    public init(_ reasoning: String, signature: String? = nil) {
        self.reasoning = reasoning
        if signature == "" {
            self.signature = nil
        } else {
            self.signature = signature
        }
    }

    public init(from sdkReasoningText: BedrockRuntimeClientTypes.ReasoningTextBlock) throws {
        guard let text = sdkReasoningText.text else {
            throw BedrockServiceError.invalidSDKType("Text is missing from ReasoningTextBlock")
        }
        self.signature = sdkReasoningText.signature
        self.reasoning = text
    }

    public func getSDKReasoningBlock() -> BedrockRuntimeClientTypes.ReasoningContentBlock {
        .reasoningtext(
            BedrockRuntimeClientTypes.ReasoningTextBlock(signature: signature, text: reasoning)
        )
    }

    public var description: String {
        if let signature {
            return "Reasoning: \(reasoning) \nSignature: \(signature)"
        }
        return "Reasoning: \(reasoning)"
    }
}
