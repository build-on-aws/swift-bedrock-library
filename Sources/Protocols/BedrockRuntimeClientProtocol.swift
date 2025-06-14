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

@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

// Protocol allows writing mocks for unit tests
public protocol BedrockRuntimeClientProtocol: Sendable {
    func invokeModel(input: InvokeModelInput) async throws -> InvokeModelOutput
    func converse(input: ConverseInput) async throws -> ConverseOutput
    func converseStream(input: ConverseStreamInput) async throws -> ConverseStreamOutput
}

extension BedrockRuntimeClient: @retroactive @unchecked Sendable, BedrockRuntimeClientProtocol {}
