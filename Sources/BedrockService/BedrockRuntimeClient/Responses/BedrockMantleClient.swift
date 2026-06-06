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

import AsyncHTTPClient
import AwsCommonRuntimeKit
import Logging
import NIOCore
import NIOHTTP1
import SmithyIdentity
import SmithyIdentityAPI

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public struct BedrockMantleClient: BedrockMantleClientProtocol {
    private let httpClient: HTTPClient
    private let logger: Logging.Logger
    private let region: String

    public init(region: String, logger: Logging.Logger? = nil) {
        self.httpClient = HTTPClient.shared
        self.region = region
        self.logger = logger ?? Logging.Logger(label: "bedrock.mantle.client")
    }

    public func sendRequest(
        body: Data,
        url: URL,
        authentication: BedrockMantleAuthentication
    ) async throws -> Data {
        let urlString = url.absoluteString

        var request = HTTPClientRequest(url: urlString)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")

        switch authentication {
        case .apiKey(let key):
            request.headers.add(name: "Authorization", value: "Bearer \(key)")
        case .sigV4(let credentialResolver):
            let signedHeaders = try await signWithSigV4(
                url: url,
                body: body,
                credentialResolver: credentialResolver
            )
            for header in signedHeaders {
                request.headers.replaceOrAdd(name: header.name, value: header.value)
            }
        }

        var buffer = ByteBuffer()
        buffer.writeBytes(body)
        request.body = .bytes(buffer)

        logger.trace(
            "Sending request to bedrock-mantle",
            metadata: ["url": .string(urlString)]
        )

        let response = try await httpClient.execute(request, timeout: .seconds(120))

        let responseBody = try await response.body.collect(upTo: 10 * 1024 * 1024)
        let responseData = Data(responseBody.readableBytesView)

        guard (200..<300).contains(response.status.code) else {
            let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw BedrockLibraryError.invalidSDKResponse(
                "bedrock-mantle returned HTTP \(response.status.code): \(errorMessage)"
            )
        }

        return responseData
    }

    private func signWithSigV4(
        url: URL,
        body: Data,
        credentialResolver: any AWSCredentialIdentityResolver
    ) async throws -> [HTTPHeader] {
        let path = url.path
        let host = url.host ?? "bedrock-mantle.\(region).api.aws"

        let identity = try await credentialResolver.getIdentity()

        let credentials = try Credentials(
            accessKey: identity.accessKey,
            secret: identity.secret,
            sessionToken: identity.sessionToken
        )

        let headers = [
            HTTPHeader(name: "Content-Type", value: "application/json"),
            HTTPHeader(name: "Host", value: host),
        ]

        let crtRequest = try HTTPRequest(
            method: "POST",
            path: path,
            headers: headers,
            body: ByteBuffer(data: body)
        )

        let signingConfig = SigningConfig(
            algorithm: .signingV4,
            signatureType: .requestHeaders,
            service: "bedrock",
            region: region,
            credentials: credentials
        )

        let signedRequest = try await Signer.signRequest(
            request: crtRequest,
            config: signingConfig
        )

        return signedRequest.getHeaders()
    }
}
