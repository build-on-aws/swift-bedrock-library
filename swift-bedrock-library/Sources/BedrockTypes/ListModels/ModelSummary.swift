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
import Foundation

public struct ModelSummary: Encodable {
    public let modelName: String
    public let providerName: String
    public let modelId: String
    public let modelArn: String
    public let modelLifecylceStatus: String
    public let responseStreamingSupported: Bool
    public let bedrockModel: BedrockModel?

    public static func getModelSummary(from sdkModelSummary: BedrockClientTypes.FoundationModelSummary) throws -> Self {

        guard let modelName = sdkModelSummary.modelName else {
            throw BedrockServiceError.notFound("BedrockClientTypes.FoundationModelSummary does not have a modelName")
        }
        guard let providerName = sdkModelSummary.providerName else {
            throw BedrockServiceError.notFound("BedrockClientTypes.FoundationModelSummary does not have a providerName")
        }
        guard let modelId = sdkModelSummary.modelId else {
            throw BedrockServiceError.notFound("BedrockClientTypes.FoundationModelSummary does not have a modelId")
        }
        guard let modelArn = sdkModelSummary.modelArn else {
            throw BedrockServiceError.notFound("BedrockClientTypes.FoundationModelSummary does not have a modelArn")
        }
        guard let modelLifecycle = sdkModelSummary.modelLifecycle else {
            throw BedrockServiceError.notFound(
                "BedrockClientTypes.FoundationModelSummary does not have a modelLifecycle"
            )
        }
        guard let sdkStatus = modelLifecycle.status else {
            throw BedrockServiceError.notFound(
                "BedrockClientTypes.FoundationModelSummary does not have a modelLifecycle.status"
            )
        }
        var status: String
        switch sdkStatus {
        case .active: status = "active"
        case .legacy: status = "legacy"
        default: throw BedrockServiceError.notSupported("Unknown BedrockClientTypes.FoundationModelLifecycleStatus")
        }
        var responseStreamingSupported = false
        if sdkModelSummary.responseStreamingSupported != nil {
            responseStreamingSupported = sdkModelSummary.responseStreamingSupported!
        }
        let bedrockModel = BedrockModel(rawValue: modelId) ?? BedrockModel(rawValue: "us.\(modelId)")

        return ModelSummary(
            modelName: modelName,
            providerName: providerName,
            modelId: modelId,
            modelArn: modelArn,
            modelLifecylceStatus: status,
            responseStreamingSupported: responseStreamingSupported,
            bedrockModel: bedrockModel
        )
    }
}
