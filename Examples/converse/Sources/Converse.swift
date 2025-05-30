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
struct Main {
    static func main() async throws {
        do {
            try await Main.converse()
        } catch {
            print("Error:\n\(error)")
        }
    }
    static func converse() async throws {
        var logger = Logger(label: "Converse")
        logger.logLevel = .debug

        let bedrock = try await BedrockService(
            region: .useast1,
            logger: logger
                // uncomment if you use SSO with AWS Identity Center
                //    authentication: .sso
        )

        // select a model that supports the converse modality
        // models must be enabled in your AWS account
        let model: BedrockModel = .nova_lite

        guard model.hasConverseModality() else {
            throw MyError.incorrectModality("\(model.name) does not support converse")
        }

        // create a request
        var builder = try ConverseRequestBuilder(with: model)
            .withPrompt("Tell me about rainbows")

        // send the request
        var reply = try await bedrock.converse(with: builder)

        print("Assistant: \(reply)")

        // create the next request
        // you can use the previous reply to continue the conversation
        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withPrompt("Do you think birds can see them too?")

        // send the next request
        reply = try await bedrock.converse(with: builder)

        print("Assistant: \(reply)")
    }

    enum MyError: Error {
        case incorrectModality(String)
    }
}
