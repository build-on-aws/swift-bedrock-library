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

/// Protocol for Amazon Bedrock Agent Runtime operations
///
/// This protocol allows writing mocks for unit tests and provides a clean interface
/// for knowledge base retrieval operations.
public protocol BedrockAgentRuntimeProtocol: Sendable {
    /// Retrieves information from a knowledge base
    /// - Parameter input: The retrieve input containing query and configuration
    /// - Returns: RetrieveOutput with the retrieved results
    /// - Throws: Error if the retrieval operation fails
    func retrieve(input: RetrieveInput) async throws -> RetrieveOutput
}

extension BedrockAgentRuntimeClient: @retroactive @unchecked Sendable, BedrockAgentRuntimeProtocol {}
