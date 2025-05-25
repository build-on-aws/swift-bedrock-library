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

public enum ContentSegment: Sendable {
    case text(Int, String)
    case reasoning(Int, String, String)  // index, text, signature
    case encryptedReasoning(Int, Data)
    case toolUse(Int, ToolUsePart)

    public var index: Int {
        switch self {
        case .text(let index, _):
            return index
        case .toolUse(let index, _):
            return index
        case .reasoning(let index, _, _):
            return index
        case .encryptedReasoning(let index, _):
            return index
        }
    }

    public var reasoningText: String? {
        switch self {
        case .reasoning(_, let text, _):
            return text
        default:
            return nil
        }
    }

    public var reasoningSignature: String? {
        switch self {
        case .reasoning(_, _, let signature):
            return signature
        default:
            return nil
        }
    }

    // MARK - Init

    package init(
        index: Int,
        sdkContentBlockDelta: BedrockRuntimeClientTypes.ContentBlockDelta,
        toolUseStarts: [ToolUseStart]
    ) throws {
        switch sdkContentBlockDelta {
        case .text(let text):
            self = .text(index, text)
        case .tooluse(let toolUseBlockDelta):
            guard let input = toolUseBlockDelta.input else {
                throw BedrockServiceError.invalidSDKType("No input found in ToolUseBlockDelta")
            }
            guard let toolUseStart = toolUseStarts.first(where: { $0.index == index })
            else {
                throw BedrockServiceError.streamingError(
                    "No ToolUse can be constructed, because no matching name and toolUseId from ContentBlockStart for ToolUseBlockDelta were found "
                )
            }
            self = .toolUse(
                index,
                ToolUsePart(
                    index: index,
                    name: toolUseStart.name,
                    toolUseId: toolUseStart.toolUseId,
                    inputPart: input
                )
            )
        case .reasoningcontent(let sdkReasoningBlock):
            switch sdkReasoningBlock {
            case .text(let reasoningText):
                self = .reasoning(index, reasoningText, "")
            case .signature(let reasoningSignature):
                self = .reasoning(index, "", reasoningSignature)
            case .redactedcontent(let data):
                self = .encryptedReasoning(index, data)
            default:
                throw BedrockServiceError.notImplemented(
                    "ReasoningBlockContent \(sdkReasoningBlock) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        default:
            throw BedrockServiceError.notImplemented(
                "ContentBlockDelta \(sdkContentBlockDelta) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
            )
        }
    }

    // MARK - convenience

    public func hasToolUse() -> Bool {
        switch self {
        case .toolUse:
            return true
        default:
            return false
        }
    }

    public func hasText() -> Bool {
        switch self {
        case .text:
            return true
        default:
            return false
        }
    }

    public func hasReasoning() -> Bool {
        switch self {
        case .reasoning:
            return true
        default:
            return false
        }
    }

    public func hasEncryptedReasoning() -> Bool {
        switch self {
        case .encryptedReasoning:
            return true
        default:
            return false
        }
    }
}
