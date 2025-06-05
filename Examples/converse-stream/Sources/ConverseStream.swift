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
            try await Main.converseStream()
        } catch {
            print("Error:\n\(error)")
        }
    }
    static func converseStream() async throws {
        var logger = Logger(label: "Converse")
        logger.logLevel = .debug

        let bedrock = try await BedrockService(
            region: .useast1,
            logger: logger
                // uncomment if you use SSO with AWS Identity Center
                // authentication: .sso
        )

        // select a model that supports the converse modality
        // models must be enabled in your AWS account
        let model: BedrockModel = .nova_lite

        guard model.hasConverseModality() else {
            throw MyError.incorrectModality("\(model.name) does not support converse")
        }

        // create a request
        let builder = try ConverseRequestBuilder(with: model)
            .withPrompt("Tell me about rainbows")

        // send the request
        let reply = try await bedrock.converseStream(with: builder)

        // the reply gives access to two streams.
        // 1. `stream` is a high-level stream that provides elements of the conversation :
        // - messageStart: this is the start of a message, it contains the role (assistant or user)
        // - text: this is a delta of the text content, it contains the partial text
        // - reasoning: this is a delta of the reasoning content, it contains the partial reasoning text
        // - toolUse: this is a buffered tool use response, it contains the tool name and id, and the input parameters
        // - message complete: this includes the complete Message, ready to be added to the history and used for future requests
        // - metaData: this is the metadata about the response, it contains statitics about the response, such as the number of tokens used and the latency
        //
        // 2. `sdkStream` is the low-level stream provided by the AWS SDK. Use it when you need low level access to the stream,
        //    such as when you want to handle the stream in a custom way or when you need to access the raw data.
        //    see : https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-call.html#conversation-inference-call-response-converse-stream
        for try await element in reply.stream {
            // process the stream elements
            switch element {
            case .messageStart(let role):
                logger.info("Message started with role: \(role)")
            case .text(_, let text):
                print(text, terminator: "")
            case .reasoning(let index, let reasoning):
                logger.info("Reasoning delta: \(reasoning)", metadata: ["index": "\(index)"])
            case .toolUse(let index, let toolUse):
                logger.info(
                    "Tool use: \(toolUse.name) with id: \(toolUse.id) and input: \(toolUse.input)",
                    metadata: ["index": "\(index)"]
                )
            case .messageComplete(_):
                print("\n")
            case .metaData(let metaData):
                logger.info("Metadata: \(metaData)")
            }
        }
    }

    enum MyError: Error {
        case incorrectModality(String)
    }
}
