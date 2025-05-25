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

public struct VideoBlock: Codable, Sendable {
    public let format: Format
    public let source: Source

    public init(format: Format, source: Source) throws {
        // https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_VideoSource.html
        guard case .bytes(let bytes) = source, !bytes.isEmpty else {
            throw BedrockServiceError.invalidName("Video source is not allowed to be empty")
        }
        self.format = format
        self.source = source
    }

    public init(format: Format, source: String) throws {
        try self.init(format: format, source: .bytes(source))
    }

    public init(format: Format, source: S3Location) throws {
        try self.init(format: format, source: .s3(source))
    }

    public init(from sdkVideoBlock: BedrockRuntimeClientTypes.VideoBlock) throws {
        guard let sdkFormat = sdkVideoBlock.format else {
            throw BedrockServiceError.decodingError(
                "Could not extract format from BedrockRuntimeClientTypes.VideoBlock"
            )
        }
        guard let sdkSource = sdkVideoBlock.source else {
            throw BedrockServiceError.decodingError(
                "Could not extract source from BedrockRuntimeClientTypes.VideoBlock"
            )
        }
        self = try VideoBlock(
            format: try VideoBlock.Format(from: sdkFormat),
            source: try VideoBlock.Source(from: sdkSource)
        )
    }

    public func getSDKVideoBlock() throws -> BedrockRuntimeClientTypes.VideoBlock {
        BedrockRuntimeClientTypes.VideoBlock(
            format: try format.getSDKVideoFormat(),
            source: try source.getSDKVideoSource()
        )
    }

    public enum Source: Codable, Sendable {
        case bytes(String)  // base64
        case s3(S3Location)

        public init(from sdkSource: BedrockRuntimeClientTypes.VideoSource) throws {
            switch sdkSource {
            case .bytes(let data):
                self = .bytes(data.base64EncodedString())
            case .s3location(let sdkS3Location):
                self = .s3(try S3Location(from: sdkS3Location))
            default:
                throw BedrockServiceError.notImplemented(
                    "VideoSource \(sdkSource) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        public func getSDKVideoSource() throws -> BedrockRuntimeClientTypes.VideoSource {
            switch self {
            case .bytes(let data):
                guard let sdkData = Data(base64Encoded: data) else {
                    throw BedrockServiceError.decodingError(
                        "Could not decode video source from base64 string. String: \(data)"
                    )
                }
                return .bytes(sdkData)
            case .s3(let s3Location):
                return .s3location(s3Location.getSDKS3Location())
            }
        }
    }

    public enum Format: Codable, Sendable {
        case flv
        case mkv
        case mov
        case mp4
        case mpeg
        case mpg
        case threeGp
        case webm
        case wmv

        public init(from sdkVideoFormat: BedrockRuntimeClientTypes.VideoFormat) throws {
            switch sdkVideoFormat {
            case .flv: self = .flv
            case .mkv: self = .mkv
            case .mov: self = .mov
            case .mp4: self = .mp4
            case .mpeg: self = .mpeg
            case .mpg: self = .mpg
            case .threeGp: self = .threeGp
            case .webm: self = .webm
            case .wmv: self = .wmv
            default:
                throw BedrockServiceError.notImplemented(
                    "VideoFormat \(sdkVideoFormat) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        public func getSDKVideoFormat() throws -> BedrockRuntimeClientTypes.VideoFormat {
            switch self {
            case .flv: return .flv
            case .mkv: return .mkv
            case .mov: return .mov
            case .mp4: return .mp4
            case .mpeg: return .mpeg
            case .mpg: return .mpg
            case .threeGp: return .threeGp
            case .webm: return .webm
            case .wmv: return .wmv
            }
        }
    }
}
