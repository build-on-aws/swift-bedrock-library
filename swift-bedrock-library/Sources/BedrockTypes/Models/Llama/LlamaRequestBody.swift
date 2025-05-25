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

public struct LlamaRequestBody: BedrockBodyCodable {
    let prompt: String
    let max_gen_len: Int?
    let temperature: Double?
    let top_p: Double?

    public init(
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?
    ) {
        self.prompt =
            "<|begin_of_text|><|start_header_id|>user<|end_header_id|>\(prompt)<|eot_id|><|start_header_id|>assistant<|end_header_id|>"
        self.max_gen_len = maxTokens
        self.temperature = temperature
        self.top_p = topP
    }
}
