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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-supported-models-features.html
public enum ConverseFeature: String, Codable, Sendable {
    case textGeneration = "text-generation"
    case vision = "vision"
    case document = "document"
    case toolUse = "tool-use"
    case systemPrompts = "system-prompts"
    case reasoning = "reasoning"
}
