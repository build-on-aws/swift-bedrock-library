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

public enum ConverseStreamElement: Sendable {
    case messageStart(Role)  // start of a message
    case text(Int, String)  // partial text
    case reasoning(Int, String)  // partial reasoning
    case toolUse(Int, ToolUseBlock)  // a complete tool use response
    case messageComplete(Message)  // complete text message (with all content blocks and reason for stop)
    case metaData(ResponseMetadata)  // metadata about the response
}

//TODO: the above struct does not manage encryptedReasoning
