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
import Testing

@testable import BedrockTypes

// MARK: ToolResultBlockTests

extension BedrockTypesTests {

    @Test("ToolResultBlock Initializer with ID and String Content")
    func toolResultBlockInitializerWithString() async throws {
        let block = ToolResultBlock("Hello, Swift!", id: "block1")
        #expect(block.id == "block1")
        #expect(block.content.count == 1)
        var reply: String
        if case .text(let text) = block.content.first {
            reply = text
        } else {
            reply = ""
        }
        #expect(reply == "Hello, Swift!")
        #expect(block.status == .success)
    }

    @Test("ToolResultBlock Initializer with ID and JSON Content")
    func toolResultBlockInitializerWithJSON() async throws {
        let json = JSON(with: ["key": JSON(with: "value")])
        let block = ToolResultBlock(json, id: "block2")
        #expect(block.id == "block2")
        #expect(block.content.count == 1)
        var value = ""
        if case .json(let json) = block.content.first {
            value = json.getValue("key") ?? ""
        }
        #expect(value == "value")
        #expect(block.status == .success)
    }

    @Test("ToolResultBlock Initializer with ID and Image Content")
    func toolResultBlockInitializerWithImage() async throws {
        let bytes = "mockmockmockmockmockmockmockmockmock"
        let image = try ImageBlock(format: .jpeg, source: bytes)
        let block = ToolResultBlock(image, id: "block3")
        #expect(block.id == "block3")
        #expect(block.content.count == 1)
        var imageContent: ImageBlock = try ImageBlock(format: .png, source: "xx")
        if case .image(let img) = block.content.first {
            imageContent = img
        }
        var imageBytes = ""
        if case .bytes(let string) = imageContent.source {
            imageBytes = string
        }
        #expect(imageBytes == bytes)
        #expect(imageContent.format == image.format)
        #expect(block.status == .success)
    }

    @Test("ToolResultBlock Initializer with Failed Status")
    func toolResultBlockFailedInitializer() async throws {
        let block = ToolResultBlock.failed("block4")
        #expect(block.id == "block4")
        #expect(block.content.isEmpty)
        #expect(block.status == .error)
    }

    @Test("ToolResultBlock Initializer with Data object")
    func toolResultBlockCodable() async throws {
        let data = """
            {
                "key": "value"
            }
            """.data(using: .utf8)!
        let block = try! ToolResultBlock(data, id: "block5")

        #expect(block.id == "block5")
        #expect(block.content.count == 1)
        var value = ""
        if case .json(let json) = block.content.first {
            value = json.getValue("key") ?? ""
        }
        #expect(value == "value")
        #expect(block.status == block.status)
    }

    @Test("ToolResultBlock Initializer with Codable Object")
    func toolResultBlockInitializerWithCodableObject() async throws {
        struct TestObject: Codable {
            let name: String
            let age: Int
        }
        let object = TestObject(name: "Jane", age: 30)
        let block = try ToolResultBlock(object, id: "block6")
        #expect(block.id == "block6")
        #expect(block.content.count == 1)
        var name = ""
        var age = 0
        if case .json(let jsonContent) = block.content.first {
            name = jsonContent.getValue("name") ?? ""
            age = jsonContent.getValue("age") ?? 0
        }
        #expect(name == "Jane")
        #expect(age == 30)
    }

    @Test("ToolResultBlock Initializer with Invalid Data Throws Error")
    func toolResultBlockInitializerWithInvalidData() async throws {
        let invalidData = Data([0x00, 0x01, 0x02])  // Invalid data for JSON decoding

        #expect(throws: BedrockServiceError.self) {
            let _ = try ToolResultBlock(invalidData, id: "block7")
        }
    }
}
