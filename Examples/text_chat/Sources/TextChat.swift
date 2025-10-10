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
struct TextChat {
    static func main() async throws {
        do {
            try await TextChat.run()
        } catch {
            print("Error:\n\(error)")
        }
    }
    static func run() async throws {
        var logger = Logger(label: "TextChat")
        logger.logLevel = .debug

        let bedrock = try await BedrockService(
            region: .useast1,
            logger: logger
                // uncomment if you use SSO with AWS Identity Center
                // authentication: .sso
        )

        // select a model that supports the converse modality
        // models must be enabled in your AWS account
        let model: BedrockModel = .claudev3_7_sonnet

        guard model.hasConverseModality() else {
            throw MyError.incorrectModality("\(model.name) does not support converse")
        }

        // a reusable var to build the requests
        var request: ConverseRequestBuilder? = nil

        // we keep track of the history of the conversation
        var history: History = []

        // while the user doesn't type "exit" or "quit"
        while true {

            print("\nYou: ", terminator: "")
            let prompt: String = readLine() ?? ""
            guard prompt.isEmpty == false else { continue }
            if ["exit", "quit"].contains(prompt.lowercased()) {
                break
            }

            print("\nAssistant: ", terminator: "")

            if request == nil {
                // create a new request
                request = try ConverseRequestBuilder(with: model)
                    .withPrompt(prompt)
            } else {
                // append the new prompt to the existing request
                // ConverseRequestBuilder is stateless, it doesn't keep track of the history
                // thanks to the `if` above, we're sure `request` is not nil
                request = try ConverseRequestBuilder(from: request!)
                    .withHistory(history)
                    .withPrompt(prompt)
            }

            // keep track of the history of the conversation
            history.append(Message(prompt))

            // send the request. We are sure `request` is not nil
            let reply = try await bedrock.converseStream(with: request!)

            for try await element in reply.stream {
                // process the stream elements
                switch element {
                case .text(_, let text):
                    print(text, terminator: "")
                case .messageComplete(let message):
                    print("\n")
                    history.append(message)
                default:
                    break
                }
            }
        }
    }

    enum MyError: Error {
        case incorrectModality(String)
    }
}
