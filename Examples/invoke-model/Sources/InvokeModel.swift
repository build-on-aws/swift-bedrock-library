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

import BedrockService
import Logging

@main
struct InvokeModel {
    static func main() async throws {
        do {
            try await InvokeModel.run()
        } catch {
            print("Error:\n\(error)")
        }
    }
    static func run() async throws {
        var logger = Logger(label: "InvokeModel")
        logger.logLevel = .debug

        let bedrock = try await BedrockService(
            region: .useast1,
            logger: logger
                // uncomment if you use SSO with AWS Identity Center
                // authentication: .sso
        )

        let model: BedrockModel = .claude_opus_v4_5

        let response = try await bedrock.completeText("who are you?", with: model)

        print(response.completion)
    }
}
