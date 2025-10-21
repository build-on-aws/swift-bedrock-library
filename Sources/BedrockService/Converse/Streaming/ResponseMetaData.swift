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

import AWSBedrockRuntime

public struct ResponseMetadata: Codable, Sendable {
    let metadata: Metadata
    public var usage: Usage? { metadata.usage }
    public var metrics: Metrics? { metadata.metrics }

    package init(from sdkMetadata: BedrockRuntimeClientTypes.ConverseStreamMetadataEvent) throws {
        self.metadata = try .init(usage: sdkMetadata.usage, metrics: sdkMetadata.metrics)
    }

    public struct Metadata: Codable, Sendable {
        let usage: Usage?
        let metrics: Metrics?
        // TODO: trace and performance are not implemented yet

        package init(
            usage: BedrockRuntimeClientTypes.TokenUsage?,
            metrics: BedrockRuntimeClientTypes.ConverseStreamMetrics?
        ) throws {
            if usage != nil {
                self.usage = try .init(from: usage!)
            } else {
                self.usage = nil
            }

            if metrics != nil {
                self.metrics = try .init(from: metrics!)
            } else {
                self.metrics = nil
            }

        }
    }
    public struct Usage: Codable, Sendable {
        package init(from sdkUsage: BedrockRuntimeClientTypes.TokenUsage) throws {
            self.inputTokens = sdkUsage.inputTokens ?? 0
            self.outputTokens = sdkUsage.outputTokens ?? 0
            self.totalTokens = sdkUsage.totalTokens ?? 0
        }

        public let inputTokens: Int
        public let outputTokens: Int
        public let totalTokens: Int
    }

    public struct Metrics: Codable, Sendable {
        package init(from sdkMetrics: BedrockRuntimeClientTypes.ConverseStreamMetrics) throws {
            self.latencyMs = Int(sdkMetrics.latencyMs ?? 0)
        }
        public let latencyMs: Int
    }
}
