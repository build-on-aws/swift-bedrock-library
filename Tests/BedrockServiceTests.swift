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

import AwsCommonRuntimeKit
import Testing

@testable import BedrockService

@Suite("BedrockService Tests")
struct BedrockServiceTests {
    let bedrock: BedrockService

    init() async throws {
        // this is a workaround for issue
        // https://github.com/awslabs/aws-sdk-swift/issues/1984
        CommonRuntimeKit.initialize()

        self.bedrock = try await BedrockService(
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    // MARK: listModels

    @Test("List all models")
    func listModels() async throws {
        let models: [ModelSummary] = try await bedrock.listModels()
        #expect(models.count == 3)
        #expect(models[0].modelId == "anthropic.claude-instant-v1")
        #expect(models[0].modelName == "Claude Instant")
        #expect(models[0].providerName == "Anthropic")
    }
}
