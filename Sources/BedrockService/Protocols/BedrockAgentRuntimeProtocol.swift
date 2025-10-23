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

@preconcurrency import AWSBedrockAgentRuntime
import AWSClientRuntime

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// Protocol allows writing mocks for unit tests
public protocol BedrockAgentRuntimeProtocol: Sendable {
    func retrieve(input: RetrieveInput) async throws -> RetrieveOutput
}

extension BedrockAgentRuntimeClient: @retroactive @unchecked Sendable, BedrockAgentRuntimeProtocol {}
