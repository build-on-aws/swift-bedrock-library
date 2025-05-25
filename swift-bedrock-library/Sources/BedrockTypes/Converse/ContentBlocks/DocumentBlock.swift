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

public struct DocumentBlock: Codable, Sendable {
    public let name: String
    public let format: Format
    public let source: Source

    public init(name: String, format: Format, source: String) throws {
        self = try Self(name: name, format: format, source: try Source(bytes: source))
    }

    public init(name: String, format: Format, source: Source) throws {
        // https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_DocumentBlock.html
        guard !name.isEmpty else {
            throw BedrockServiceError.invalidName("Document name is not allowed to be empty")
        }
        guard name.contains(/^[a-zA-Z()\[\]\-](?:[a-zA-Z()\[\]\-]|\s(?!\s))*$/) else {
            throw BedrockServiceError.invalidName(
                "Document name must consist of only lowercase letter, uppercase letters, parentheses, square brackets, whitespace characters (no more than one in a row) and hyphens"
            )
        }
        guard name.count <= 200 else {
            throw BedrockServiceError.invalidName("Document name must be no longer than 200 characters")
        }

        self.name = name
        self.format = format
        self.source = source
    }

    public init(from sdkDocumentBlock: BedrockRuntimeClientTypes.DocumentBlock) throws {
        guard let name = sdkDocumentBlock.name else {
            throw BedrockServiceError.decodingError(
                "Could not extract name from BedrockRuntimeClientTypes.DocumentBlock"
            )
        }
        guard let sdkFormat = sdkDocumentBlock.format else {
            throw BedrockServiceError.decodingError(
                "Could not extract format from BedrockRuntimeClientTypes.DocumentBlock"
            )
        }
        guard let sdkSource = sdkDocumentBlock.source else {
            throw BedrockServiceError.decodingError(
                "Could not extract source from BedrockRuntimeClientTypes.DocumentSource"
            )
        }
        let format = try Format(from: sdkFormat)
        let source = try Source(from: sdkSource)
        try self.init(name: name, format: format, source: source)
    }

    public func getSDKDocumentBlock() throws -> BedrockRuntimeClientTypes.DocumentBlock {
        BedrockRuntimeClientTypes.DocumentBlock(
            format: format.getSDKDocumentFormat(),
            name: name,
            source: try source.getSDKDocumentSource()
        )
    }

    public enum Format: Codable, Sendable {
        case csv
        case doc
        case docx
        case html
        case md
        case pdf
        case txt
        case xls
        case xlsx

        public init(from sdkDocumentFormat: BedrockRuntimeClientTypes.DocumentFormat) throws {
            switch sdkDocumentFormat {
            case .csv: self = .csv
            case .doc: self = .doc
            case .docx: self = .docx
            case .html: self = .html
            case .md: self = .md
            case .pdf: self = .pdf
            case .txt: self = .txt
            case .xls: self = .xls
            case .xlsx: self = .xlsx
            default:
                throw BedrockServiceError.notImplemented(
                    "DocumentFormat \(sdkDocumentFormat) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        public func getSDKDocumentFormat() -> BedrockRuntimeClientTypes.DocumentFormat {
            switch self {
            case .csv: return .csv
            case .doc: return .doc
            case .docx: return .docx
            case .html: return .html
            case .md: return .md
            case .pdf: return .pdf
            case .txt: return .txt
            case .xls: return .xls
            case .xlsx: return .xlsx
            }
        }
    }

    public enum Source: Codable, Sendable {
        case bytes(String)
        case s3(S3Location)

        public init(bytes: String) throws {
            guard !bytes.isEmpty else {
                throw BedrockServiceError.invalidName("Document source is not allowed to be empty")
            }
            self = .bytes(bytes)
        }

        public init(from sdkSource: BedrockRuntimeClientTypes.DocumentSource) throws {
            switch sdkSource {
            case .bytes(let data):
                self = .bytes(data.base64EncodedString())
            case .s3location(let sdkS3Location):
                self = .s3(try S3Location(from: sdkS3Location))
            default:
                throw BedrockServiceError.notImplemented(
                    "DocumentSource \(sdkSource) is not implemented by BedrockService or not implemented by BedrockRuntimeClientTypes in case of `sdkUnknown`"
                )
            }
        }

        public func getSDKDocumentSource() throws -> BedrockRuntimeClientTypes.DocumentSource {
            switch self {
            case .bytes(let data):
                guard let sdkData = Data(base64Encoded: data) else {
                    throw BedrockServiceError.decodingError(
                        "Could not decode document source from base64 string. String: \(data)"
                    )
                }
                return .bytes(sdkData)
            case .s3(let s3Location):
                return .s3location(s3Location.getSDKS3Location())
            }
        }
    }
}
