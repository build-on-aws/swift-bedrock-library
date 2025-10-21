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

//TODO: split in two structs : BedrockModelError and BedrockLibraryError
public enum BedrockLibraryError: Error, Equatable {
    public static func == (lhs: BedrockLibraryError, rhs: BedrockLibraryError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidParameter(_, _), .invalidParameter(_, _)):
            return true
        case (.invalidModality(_, _, _), .invalidModality(_, _, _)):
            return true
        case (.invalidPrompt(_), .invalidPrompt(_)):
            return true
        case (.invalid(_), .invalid(_)):
            return true
        case (.invalidStopSequences(_, _), .invalidStopSequences(_, _)):
            return true
        case (.invalidURI(_), .invalidURI(_)):
            return true
        case (.invalidConverseReply(_), .invalidConverseReply(_)):
            return true
        case (.invalidName(_), .invalidName(_)):
            return true
        case (.streamingError(_), .streamingError(_)):
            return true
        case (.invalidSDKType(_), .invalidSDKType(_)):
            return true
        case (.ConverseRequestBuilder(_), .ConverseRequestBuilder(_)):
            return true
        case (.invalidSDKResponse(_), .invalidSDKResponse(_)):
            return true
        case (.invalidSDKResponseBody(_), .invalidSDKResponseBody(_)):
            return true
        case (.completionNotFound(_), .completionNotFound(_)):
            return true
        case (.encodingError(_), .encodingError(_)):
            return true
        case (.decodingError(_), .decodingError(_)):
            return true
        case (.notImplemented(_), .notImplemented(_)):
            return true
        case (.notSupported(_), .notSupported(_)):
            return true
        case (.notFound(_), .notFound(_)):
            return true
        case (.authenticationFailed(_), .authenticationFailed(_)):
            return true
        case (.inputTooLong(_), .inputTooLong(_)):
            return true
        case (.unknownError(_), .unknownError(_)):
            return true
        default:
            return false
        }
    }
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
    case inputTooLong(String)
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
            let valueAsString = value != nil ? String(data: value!, encoding: .utf8) ?? "" : "nil"
            return "Invalid SDK response body: \(valueAsString)"
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
        case .inputTooLong(let message):
            return "Input too long: \(message)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        }
    }
}
