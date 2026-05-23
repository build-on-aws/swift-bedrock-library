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

@preconcurrency import AWSBedrockRuntime

public typealias ConverseStreamingRequest = ConverseRequest
extension ConverseStreamingRequest {
    func getConverseStreamingInput(forRegion region: Region) throws -> ConverseStreamInput {
        let sdkOutputConfig: BedrockRuntimeClientTypes.OutputConfig?
        if let outputFormat {
            sdkOutputConfig = BedrockRuntimeClientTypes.OutputConfig(
                textFormat: try outputFormat.getSDKOutputFormat()
            )
        } else {
            sdkOutputConfig = nil
        }

        return ConverseStreamInput(
            additionalModelRequestFields: try getAdditionalModelRequestFields(),
            inferenceConfig: inferenceConfig?.getSDKInferenceConfig(),
            messages: try getSDKMessages(),
            modelId: model.getModelIdWithCrossRegionInferencePrefix(region: region),
            outputConfig: sdkOutputConfig,
            serviceTier: BedrockRuntimeClientTypes.ServiceTier(type: .init(rawValue: serviceTier.rawValue)),
            system: getSDKSystemPrompts(),
            toolConfig: try toolConfig?.getSDKToolConfig()
        )
    }
}
