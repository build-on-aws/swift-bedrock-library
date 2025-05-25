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

public struct DeepSeekResponseBody: ContainsTextCompletion {
    private let choices: [Choice]

    private struct Choice: Codable {
        let text: String
        let stop_reason: String
    }

    public func getTextCompletion() throws -> TextCompletion {
        guard choices.count > 0 else {
            throw BedrockServiceError.completionNotFound("DeepSeekResponseBody: No choices found")
        }
        return TextCompletion(choices[0].text)
    }

}
