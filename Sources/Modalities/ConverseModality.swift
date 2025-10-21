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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A protocol defining the interface for models that support conversational interactions
/// 
/// Converse modalities enable back-and-forth conversations with AI models,
/// supporting features like system prompts, tool usage, and multi-modal content.
public protocol ConverseModality: Modality {
    /// The parameters configuration for converse operations
    var converseParameters: ConverseParameters { get }
    /// The supported features for converse operations
    var converseFeatures: [ConverseFeature] { get }

    /// Returns the parameters configuration for converse operations
    /// - Returns: ConverseParameters containing model-specific parameter constraints
    func getConverseParameters() -> ConverseParameters
    
    /// Returns the supported features for converse operations
    /// - Returns: Array of ConverseFeature indicating what capabilities are available
    func getConverseFeatures() -> [ConverseFeature]
}

/// A protocol for models that support both conversational interactions and streaming responses
/// 
/// Streaming converse modalities can provide real-time, incremental responses
/// during conversation, enabling more interactive user experiences.
public protocol ConverseStreamingModality: ConverseModality, StreamingModality {}

/// Default implementation for ConverseModality protocol methods
extension ConverseModality {

    func getConverseParameters() -> ConverseParameters {
        converseParameters
    }

    func getConverseFeatures() -> [ConverseFeature] {
        converseFeatures
    }
}
