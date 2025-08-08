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

var logger = Logger(label: "OpenAIConverse")
logger.logLevel = .debug

let bedrock = try await BedrockService(
    region: .uswest2,
    logger: logger,
)

var builder = try ConverseRequestBuilder(with: .openai_gpt_oss_20b)
    .withPrompt("Who are you?")

var reply = try await bedrock.converse(with: builder)

print("Assistant: \(reply)")
