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

public struct TextGenerationParameters: Parameters {
    public let temperature: Parameter<Double>
    public let maxTokens: Parameter<Int>
    public let topP: Parameter<Double>
    public let topK: Parameter<Int>
    public let prompt: PromptParams
    public let stopSequences: StopSequenceParams
    public let serviceTier: ServiceTier

    public init(
        temperature: Parameter<Double>,
        maxTokens: Parameter<Int>,
        topP: Parameter<Double>,
        topK: Parameter<Int>,
        stopSequences: StopSequenceParams,
        maxPromptSize: Int?,
        serviceTier: ServiceTier = .default
    ) {
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.topK = topK
        self.prompt = PromptParams(maxSize: maxPromptSize)
        self.stopSequences = stopSequences
        self.serviceTier = serviceTier
    }

    package func validate(
        prompt: String? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        stopSequences: [String]? = nil
    ) throws {
        if let prompt = prompt {
            try self.prompt.validateValue(prompt)
        }
        if let temperature = temperature {
            try self.temperature.validateValue(temperature)
        }
        if let maxTokens = maxTokens {
            try self.maxTokens.validateValue(maxTokens)
        }
        if let topP = topP {
            try self.topP.validateValue(topP)
        }
        if let topK = topK {
            try self.topK.validateValue(topK)
        }
        if let stopSequences = stopSequences {
            try self.stopSequences.validateValue(stopSequences)
        }
    }
}
