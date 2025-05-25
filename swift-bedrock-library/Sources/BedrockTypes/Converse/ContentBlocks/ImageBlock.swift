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

@preconcurrency import AWSBedrockRuntime
import Foundation

public struct ImageBlock: Codable, Sendable {
    public let format: Format
    public let source: Source

    public init(format: Format, source: String) throws {
        self = try .init(format: format, source: .bytes(source))
    }

    public init(format: Format, source: Source) throws {
        // https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_ImageSource.html
        self.format = format
        self.source = source
    }

    public init(from sdkImageBlock: BedrockRuntimeClientTypes.ImageBlock) throws {
        guard let sdkFormat = sdkImageBlock.format else {
            throw BedrockServiceError.decodingError(
                "Could not extract format from BedrockRuntimeClientTypes.ImageBlock"
            )
        }
        guard let sdkImageSource = sdkImageBlock.source else {
            throw BedrockServiceError.decodingError(
                "Could not extract source from BedrockRuntimeClientTypes.ImageBlock"
            )
        }
        let format = try Format(from: sdkFormat)
        let source = try Source(from: sdkImageSource)
        self = try .init(format: format, source: source)
    }

    public func getSDKImageBlock() throws -> BedrockRuntimeClientTypes.ImageBlock {
        BedrockRuntimeClientTypes.ImageBlock(
            format: format.getSDKImageFormat(),
            source: try source.getSDKImageSource()
        )
    }

    public enum Format: Codable, Sendable {
        case gif
        case jpeg
        case png
        case webp

        public init(from sdkImageFormat: BedrockRuntimeClientTypes.ImageFormat) throws {
            switch sdkImageFormat {
            case .gif: self = .gif
            case .jpeg: self = .jpeg
            case .png: self = .png
            case .webp: self = .webp
            default:
                throw BedrockServiceError.notImplemented(
                    "ImageFormat \(sdkImageFormat) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        public func getSDKImageFormat() -> BedrockRuntimeClientTypes.ImageFormat {
            switch self {
            case .gif: return .gif
            case .jpeg: return .jpeg
            case .png: return .png
            case .webp: return .webp
            }
        }
    }

    public enum Source: Codable, Sendable {
        case bytes(String)
        case s3(S3Location)

        public init(from sdkSource: BedrockRuntimeClientTypes.ImageSource) throws {
            switch sdkSource {
            case .bytes(let data):
                guard !data.isEmpty else {
                    throw BedrockServiceError.invalidName("Image source is not allowed to be empty")
                }
                self = .bytes(data.base64EncodedString())
            case .s3location(let sdkS3Location):
                self = .s3(try S3Location(from: sdkS3Location))
            default:
                throw BedrockServiceError.notImplemented(
                    "ImageSource \(sdkSource) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        public func getSDKImageSource() throws -> BedrockRuntimeClientTypes.ImageSource {
            switch self {
            case .bytes(let data):
                guard let sdkData = Data(base64Encoded: data) else {
                    throw BedrockServiceError.decodingError(
                        "Could not decode image source from base64 string. String: \(data)"
                    )
                }
                return .bytes(sdkData)
            case .s3(let s3Location):
                return .s3location(s3Location.getSDKS3Location())
            }
        }
    }
}
