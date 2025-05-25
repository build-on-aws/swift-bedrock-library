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

@preconcurrency import AWSBedrock
import AWSClientRuntime
import AWSSDKIdentity
import BedrockService
import BedrockTypes
import Foundation

public struct MockBedrockClient: BedrockClientProtocol {
    public init() {}

    public func listFoundationModels(
        input: ListFoundationModelsInput
    ) async throws
        -> ListFoundationModelsOutput
    {
        ListFoundationModelsOutput(
            // customizationsSupported: [BedrockClientTypes.ModelCustomization]? = nil,
            // inferenceTypesSupported: [BedrockClientTypes.InferenceType]? = nil,
            // inputModalities: [BedrockClientTypes.ModelModality]? = nil,
            // modelArn: Swift.String? = nil,
            // modelId: Swift.String? = nil,
            // modelLifecycle: BedrockClientTypes.FoundationModelLifecycle? = nil,
            // modelName: Swift.String? = nil,
            // outputModalities: [BedrockClientTypes.ModelModality]? = nil,
            // providerName: Swift.String? = nil,
            // responseStreamingSupported: Swift.Bool? = nil
            modelSummaries: [
                BedrockClientTypes.FoundationModelSummary(
                    modelArn: "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-instant-v1",
                    modelId: "anthropic.claude-instant-v1",
                    modelLifecycle: BedrockClientTypes.FoundationModelLifecycle(status: .active),
                    modelName: "Claude Instant",
                    providerName: "Anthropic",
                    responseStreamingSupported: false
                ),
                BedrockClientTypes.FoundationModelSummary(
                    modelArn: "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-instant-v2",
                    modelId: "anthropic.claude-instant-v2",
                    modelLifecycle: BedrockClientTypes.FoundationModelLifecycle(status: .active),
                    modelName: "Claude Instant 2",
                    providerName: "Anthropic",
                    responseStreamingSupported: true
                ),
                BedrockClientTypes.FoundationModelSummary(
                    modelArn: "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-instant-v3",
                    modelId: "unknownID",
                    modelLifecycle: BedrockClientTypes.FoundationModelLifecycle(status: .active),
                    modelName: "Claude Instant 3",
                    providerName: "Anthropic",
                    responseStreamingSupported: false
                ),
            ])
    }
}
