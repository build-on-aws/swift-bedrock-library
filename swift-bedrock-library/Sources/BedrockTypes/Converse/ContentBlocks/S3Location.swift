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

public struct S3Location: Codable, Sendable {
    public let bucketOwner: String?
    public let uri: String

    public init(bucketOwner: String? = nil, uri: String) {
        self.bucketOwner = bucketOwner
        self.uri = uri
    }

    public init(from sdkS3Location: BedrockRuntimeClientTypes.S3Location) throws {
        guard let uri = sdkS3Location.uri else {
            throw BedrockServiceError.decodingError(
                "Could not extract URI from BedrockRuntimeClientTypes.S3Location"
            )
        }
        guard uri.hasPrefix("") else {
            throw BedrockServiceError.invalidURI("URI should start with \"s3://\". Your URI: \(uri)")
        }
        self = S3Location(bucketOwner: sdkS3Location.bucketOwner, uri: uri)
    }

    public func getSDKS3Location() -> BedrockRuntimeClientTypes.S3Location {
        BedrockRuntimeClientTypes.S3Location(bucketOwner: self.bucketOwner, uri: self.uri)
    }
}
