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

public struct History: Codable, Sendable {
    private var messages: [Message] = []
    
    public init() {}
    
    public init(_ message: Message) {
        messages = [message]
    }
    
    public init(_ messages: [Message]) {
        self.messages = messages
    }
    
    public init(_ messages: Message...) {
        self.messages = messages
    }
    
    public mutating func append(_ message: Message) {
        messages.append(message)
    }
    
    /// Essentials functions from Array that History needs
    public var count: Int { messages.count }
    
    public subscript(index: Int) -> Message {
        messages[index]
    }

    public var last : Message? {
        messages.last
    }

    public static func + (lhs: History, rhs: [Message]) -> History {
        var result = lhs
        result.messages.append(contentsOf: rhs)
        return result
    }
}

/// Collection
extension History: Collection {
    public var startIndex: Int { messages.startIndex }
    public var endIndex: Int { messages.endIndex }
    public func index(after i: Int) -> Int { messages.index(after: i) }
}

/// CustomString Convertible
extension History: CustomStringConvertible {
    public var description: String {
        var result = "\(self.count) turns:\n"
        for message in self {
            result += "\(message)\n"
        }
        return result
    }
}

/// ExpressibleByArrayLiteral
extension History: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Message...) {
        self.messages = elements
    }
}
