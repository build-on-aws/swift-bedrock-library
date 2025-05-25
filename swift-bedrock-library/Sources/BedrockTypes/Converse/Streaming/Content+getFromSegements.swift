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

import Foundation

extension Content {
    static func getFromSegements(with index: Int, from segments: [ContentSegment]) throws -> Content {
        var text = ""
        var toolUseName = ""
        var toolUseId = ""
        var toolUseInput = ""
        var reasoningText = ""
        var reasoningSignature = ""
        var encryptedReasoning: Data? = nil

        for segment in segments {
            if segment.index == index {
                switch segment {

                case .text(_, let textPart):
                    text += textPart

                case .reasoning(_, let textPart, let signaturePart):
                    guard text == "" else {
                        throw BedrockServiceError.streamingError(
                            "A reasoning segment was found in a contentBlock that already contained text segments"
                        )
                    }
                    reasoningText += textPart
                    reasoningSignature += signaturePart

                case .toolUse(_, let toolUsePart):
                    guard text == "" else {
                        throw BedrockServiceError.streamingError(
                            "A toolUse segment was found in a contentBlock that already contained text segments"
                        )
                    }
                    if toolUseName == "" {
                        toolUseName = toolUsePart.name
                    } else if toolUseName != toolUsePart.name {
                        throw BedrockServiceError.streamingError(
                            "A toolUse segment was found in a contentBlock that contained multiple tools with different toolUseName"
                        )
                    }
                    if toolUseId == "" {
                        toolUseId = toolUsePart.toolUseId
                    } else if toolUseId != toolUsePart.toolUseId {
                        throw BedrockServiceError.streamingError(
                            "A toolUse segment was found in a contentBlock that contained multiple tools with different toolUseId"
                        )
                    }
                    toolUseInput += toolUsePart.inputPart

                case .encryptedReasoning(_, let data):
                    guard text == "" else {
                        throw BedrockServiceError.streamingError(
                            "An encrypted reasoning segment was found in a contentBlock that already contained text segments"
                        )
                    }
                    guard reasoningText == "", reasoningSignature == "" else {
                        throw BedrockServiceError.streamingError(
                            "An encrypted reasoning segment was found in a contentBlock that already contained reasoning segments"
                        )
                    }
                    encryptedReasoning = data
                    break
                }
            }
        }
        if text != "" {
            return .text(text)
        } else if reasoningText != "" {
            return .reasoning(Reasoning(reasoningText, signature: reasoningSignature))
        } else if toolUseInput != "", toolUseName != "", toolUseId != "" {
            return .toolUse(ToolUseBlock(id: toolUseId, name: toolUseName, input: try JSON(from: toolUseInput)))
        } else if let encryptedReasoning {
            return .encryptedReasoning(EncryptedReasoning(encryptedReasoning))
        } else {
            throw BedrockServiceError.streamingError("No content found in ContentSegments to create Content")
        }
    }
}
