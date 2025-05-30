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

public struct ConverseParameters: Parameters {
    public let temperature: Parameter<Double>
    public let maxTokens: Parameter<Int>
    public let topP: Parameter<Double>
    public let prompt: PromptParams
    public let stopSequences: StopSequenceParams
    public let maxReasoningTokens: Parameter<Int>

    public init(
        temperature: Parameter<Double>,
        maxTokens: Parameter<Int>,
        topP: Parameter<Double>,
        stopSequences: StopSequenceParams,
        maxPromptSize: Int?,
        maxReasoningTokens: Parameter<Int> = .notSupported(.maxReasoningTokens)
    ) {
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.prompt = PromptParams(maxSize: maxPromptSize)
        self.stopSequences = stopSequences
        self.maxReasoningTokens = maxReasoningTokens
    }

    public init(
        textGenerationParameters: TextGenerationParameters,
        maxReasoningTokens: Parameter<Int> = .notSupported(.maxReasoningTokens)
    ) {
        self.temperature = textGenerationParameters.temperature
        self.maxTokens = textGenerationParameters.maxTokens
        self.topP = textGenerationParameters.topP
        self.prompt = textGenerationParameters.prompt
        self.stopSequences = textGenerationParameters.stopSequences
        self.maxReasoningTokens = maxReasoningTokens
    }

    package func validate(
        prompt: String? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        stopSequences: [String]? = nil
    ) throws {
        if let prompt {
            try self.prompt.validateValue(prompt)
        }
        if let maxTokens {
            try self.maxTokens.validateValue(maxTokens)
        }
        if let temperature {
            try self.temperature.validateValue(temperature)
        }
        if let topP {
            try self.topP.validateValue(topP)
        }
        if let stopSequences {
            try self.stopSequences.validateValue(stopSequences)
        }
    }
}
