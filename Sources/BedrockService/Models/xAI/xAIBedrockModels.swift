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

// https://docs.aws.amazon.com/bedrock/latest/userguide/model-card-xai-grok-4-3.html

extension BedrockModel {
    public static let grok_4_3: BedrockModel = BedrockModel(
        id: "xai.grok-4.3",
        name: "xAI Grok 4.3",
        modality: GrokText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 2, defaultValue: 0.7),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: 131_072, defaultValue: 131_072),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.95),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
}
