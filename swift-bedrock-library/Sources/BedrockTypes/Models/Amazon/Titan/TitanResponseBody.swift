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

public struct TitanResponseBody: ContainsTextCompletion {
    private let inputTextTokenCount: Int
    private let results: [Result]

    public func getTextCompletion() throws -> TextCompletion {
        guard results.count > 0 else {
            throw BedrockServiceError.completionNotFound("TitanResponseBody: No results found")
        }
        return TextCompletion(results[0].outputText)
    }

    private struct Result: Codable {
        let tokenCount: Int
        let outputText: String
        let completionReason: String
    }
}
