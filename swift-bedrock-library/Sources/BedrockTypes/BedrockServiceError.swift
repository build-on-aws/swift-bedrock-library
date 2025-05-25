//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Foundation Models Playground open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Foundation Models Playground project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Foundation Models Playground project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

public enum BedrockServiceError: Error {
    case invalidParameter(ParameterName, String)
    case invalidModality(BedrockModel, Modality, String)
    case invalidPrompt(String)
    case invalid(String)
    case invalidStopSequences([String], String)
    case invalidURI(String)
    case invalidConverseReply(String)
    case invalidName(String)
    case streamingError(String)
    case invalidSDKType(String)
    case ConverseRequestBuilder(String)
    case invalidSDKResponse(String)
    case invalidSDKResponseBody(Data?)
    case completionNotFound(String)
    case encodingError(String)
    case decodingError(String)
    case notImplemented(String)
    case notSupported(String)
    case notFound(String)
    case authenticationFailed(String)
    case unknownError(String)

    public var message: String {
        switch self {
        case .invalidParameter(let parameterName, let message):
            return "Invalid parameter \(parameterName): \(message)"
        case .invalidModality(let model, let modality, let message):
            return "Invalid modality \(modality.getName()) for model \(model.name): \(message)"
        case .invalidPrompt(let message):
            return "Invalid prompt with value \(message)"
        case .invalid(let message):
            return "Invalid value: \(message)"
        case .invalidStopSequences(let stopSequences, let message):
            return "Invalid stop sequences \(stopSequences): \(message)"
        case .invalidURI(let message):
            return "Invalid URI: \(message)"
        case .invalidConverseReply(let message):
            return "Invalid converse reply: \(message)"
        case .invalidName(let message):
            return "Invalid name: \(message)"
        case .streamingError(let message):
            return "Streaming error: \(message)"
        case .invalidSDKType(let message):
            return "Invalid SDK type: \(message)"
        case .ConverseRequestBuilder(let message):
            return "Converse request builder error: \(message)"
        case .invalidSDKResponse(let message):
            return "Invalid SDK response: \(message)"
        case .invalidSDKResponseBody(let value):
            return "Invalid SDK response body: \(String(describing: value))"
        case .completionNotFound(let message):
            return "Completion not found: \(message)"
        case .encodingError(let message):
            return "Encoding error \(message)"
        case .decodingError(let message):
            return "Decoding error \(message)"
        case .notImplemented(let message):
            return "Not implemented: \(message)"
        case .notSupported(let message):
            return "Not supported: \(message)"
        case .notFound(let message):
            return "Not found: \(message)"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}
