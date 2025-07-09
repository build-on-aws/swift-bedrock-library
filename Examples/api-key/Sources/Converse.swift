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
        var logger = Logger(label: "APIKey")
        logger.logLevel = .debug

        // generate an API Key in the AWS Management Console
        // see https://docs.aws.amazon.com/bedrock/latest/userguide/api-keys-generate.html
        let bedrock = try await BedrockService(
            region: .useast1,
            logger: logger,
            authentication: .apiKey(key: myApiKey) // define your API Key in APIKey.swift
        )

        // select a model that supports the converse modality
        // models must be enabled in your AWS account
        let model: BedrockModel = .nova_lite

        guard model.hasConverseModality() else {
            throw MyError.incorrectModality("\(model.name) does not support converse")
        }

        // create a request
        let builder = try ConverseRequestBuilder(with: model)
            .withPrompt("What is an API key?")

        // send the request
        let reply = try await bedrock.converse(with: builder)

        print("Assistant: \(reply)")
    }

    enum MyError: Error {
        case incorrectModality(String)
    }
}
