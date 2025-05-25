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

struct LlamaResponseBody: ContainsTextCompletion {
    let generation: String
    let prompt_token_count: Int
    let generation_token_count: Int
    let stop_reason: String

    public func getTextCompletion() throws -> TextCompletion {
        TextCompletion(String(generation.trimmingPrefix("\n\n")))
        // sidenote: when you format the prompt the output starts with "\n\n", when you don't it starts with "\n"
    }
}
