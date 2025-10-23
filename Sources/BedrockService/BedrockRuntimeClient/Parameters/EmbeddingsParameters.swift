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

public struct EmbeddingsParameters: Parameters {
    public let maxInputTokens: Parameter<Int>
    public let maxInputChars: Parameter<Int>
    public let outputVectorSize: Parameter<Int>
    public let prompt: PromptParams

    public init(
        maxInputTokens: Parameter<Int>,
        maxInputChars: Parameter<Int>,
        outputVectorSize: Parameter<Int>,
        maxPromptSize: Int?
    ) {
        self.maxInputTokens = maxInputTokens
        self.maxInputChars = maxInputChars
        self.outputVectorSize = outputVectorSize
        self.prompt = PromptParams(maxSize: self.maxInputChars.defaultValue)
    }

    package func validate(
        prompt: String? = nil,
        maxInputTokens: Int? = nil,
        maxInputChars: Int? = nil,
        outputVectorSize: Int? = nil,
    ) throws {
        if let prompt = prompt {
            try self.prompt.validateValue(prompt)
        }
        if let maxInputTokens = maxInputTokens {
            try self.maxInputTokens.validateValue(maxInputTokens)
        }
        if let maxInputChars = maxInputChars {
            try self.maxInputChars.validateValue(maxInputChars)
        }
        if let outputVectorSize = outputVectorSize {
            try self.outputVectorSize.validateValue(outputVectorSize)
        }
    }
}
