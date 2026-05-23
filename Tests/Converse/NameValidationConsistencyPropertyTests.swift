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

import Foundation
import Testing

@testable import BedrockService

/// **Validates: Requirements 7.1, 7.2**
///
/// Property 3: Name Validation Consistency
/// For any string, OutputFormat name validation and Tool name validation
/// produce the same accept/reject result — both use the pattern [a-zA-Z0-9_-]+
/// and reject empty strings.
@Suite("Name Validation Consistency Property Tests")
struct NameValidationConsistencyPropertyTests {

    // A valid JSON schema to use when creating OutputFormat instances
    private let validSchema = JSON(with: .object(["type": .string("object")]))

    // A valid JSON input schema to use when creating Tool instances
    private let validInputSchema = JSON(with: .object(["type": .string("object")]))

    /// Attempts to create an OutputFormat with the given name.
    /// Returns true if creation succeeds, false if it throws.
    private func outputFormatAccepts(_ name: String) -> Bool {
        do {
            let _ = try OutputFormat(schema: validSchema, name: name)
            return true
        } catch {
            return false
        }
    }

    /// Attempts to create a Tool with the given name.
    /// Returns true if creation succeeds, false if it throws.
    private func toolAccepts(_ name: String) -> Bool {
        do {
            let _ = try Tool(name: name, inputSchema: validInputSchema)
            return true
        } catch {
            return false
        }
    }

    /// Returns the error thrown when creating an OutputFormat with the given name, or nil if no error.
    private func outputFormatError(_ name: String) -> BedrockLibraryError? {
        do {
            let _ = try OutputFormat(schema: validSchema, name: name)
            return nil
        } catch let error as BedrockLibraryError {
            return error
        } catch {
            return nil
        }
    }

    /// Returns the error thrown when creating a Tool with the given name, or nil if no error.
    private func toolError(_ name: String) -> BedrockLibraryError? {
        do {
            let _ = try Tool(name: name, inputSchema: validInputSchema)
            return nil
        } catch let error as BedrockLibraryError {
            return error
        } catch {
            return nil
        }
    }

    /// Generates a variety of test strings covering valid names, empty strings,
    /// strings with special characters, unicode, spaces, etc.
    private var testNames: [String] {
        var names: [String] = []

        // Empty string
        names.append("")

        // Valid names: alphanumeric, underscores, hyphens
        names.append("a")
        names.append("Z")
        names.append("0")
        names.append("_")
        names.append("-")
        names.append("valid_name")
        names.append("valid-name")
        names.append("ValidName123")
        names.append("a-b_c-d")
        names.append("ALLCAPS")
        names.append("lowercase")
        names.append("MiXeD_CaSe-123")
        names.append("___")
        names.append("---")
        names.append("a_b_c")
        names.append("test-schema_v2")
        names.append("x")
        names.append("A1_b2-C3")

        // Strings with special characters (should be rejected if they contain ONLY invalid chars)
        names.append("!!!")
        names.append("@#$")
        names.append("...")
        names.append("***")
        names.append("   ")
        names.append("\t\t")
        names.append("~~~")
        names.append("()")
        names.append("[]")
        names.append("{}")
        names.append("<>")
        names.append("++=")
        names.append("///")
        names.append("\\\\")
        names.append("|||")
        names.append("^^^")
        names.append("&&&")
        names.append("%%%")

        // Mixed: valid chars mixed with invalid chars (contains match)
        names.append("hello world")
        names.append("name with spaces")
        names.append("name@domain")
        names.append("path/to/file")
        names.append("key=value")
        names.append("hello!")
        names.append("test.name")
        names.append("name\ttab")
        names.append("name\nnewline")
        names.append("a b")
        names.append(" leading")
        names.append("trailing ")
        names.append("mid dle")

        // Unicode characters
        names.append("café")
        names.append("日本語")
        names.append("émoji")
        names.append("über")
        names.append("naïve")
        names.append("🎉")
        names.append("hello🌍")
        names.append("αβγ")
        names.append("中文名")

        // Edge cases
        names.append(String(repeating: "a", count: 1))
        names.append(String(repeating: "a", count: 100))
        names.append(String(repeating: "-", count: 50))
        names.append(String(repeating: "_", count: 50))

        // Randomly generated strings with various character sets
        let validChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
        let invalidChars = " !@#$%^&*()+=[]{}|;:',.<>?/~`\"\\\t\n"

        // Generate random valid names
        for length in 1...10 {
            var name = ""
            for _ in 0..<length {
                let index = validChars.index(
                    validChars.startIndex,
                    offsetBy: Int.random(in: 0..<validChars.count)
                )
                name.append(validChars[index])
            }
            names.append(name)
        }

        // Generate random invalid-only names
        for length in 1...5 {
            var name = ""
            for _ in 0..<length {
                let index = invalidChars.index(
                    invalidChars.startIndex,
                    offsetBy: Int.random(in: 0..<invalidChars.count)
                )
                name.append(invalidChars[index])
            }
            names.append(name)
        }

        // Generate random mixed names (valid + invalid chars)
        let allChars = validChars + invalidChars
        for length in 2...8 {
            var name = ""
            for _ in 0..<length {
                let index = allChars.index(
                    allChars.startIndex,
                    offsetBy: Int.random(in: 0..<allChars.count)
                )
                name.append(allChars[index])
            }
            names.append(name)
        }

        return names
    }

    // MARK: - Property Test

    @Test("Property 3: OutputFormat and Tool name validation produce the same accept/reject result for all strings")
    func nameValidationConsistency() throws {
        for name in testNames {
            let outputFormatResult = outputFormatAccepts(name)
            let toolResult = toolAccepts(name)

            #expect(
                outputFormatResult == toolResult,
                "Name validation inconsistency for \"\(name)\": OutputFormat \(outputFormatResult ? "accepts" : "rejects"), Tool \(toolResult ? "accepts" : "rejects")"
            )
        }
    }

    @Test("Property 3: When both reject a name, both throw BedrockLibraryError.invalidName")
    func bothRejectWithInvalidNameError() throws {
        for name in testNames {
            let ofError = outputFormatError(name)
            let toolErr = toolError(name)

            // If both reject, verify both throw invalidName
            if ofError != nil && toolErr != nil {
                #expect(
                    ofError == BedrockLibraryError.invalidName(""),
                    "OutputFormat should throw invalidName for \"\(name)\", got: \(String(describing: ofError))"
                )
                #expect(
                    toolErr == BedrockLibraryError.invalidName(""),
                    "Tool should throw invalidName for \"\(name)\", got: \(String(describing: toolErr))"
                )
            }

            // If one accepts and the other rejects, that's a consistency violation
            let ofAccepts = ofError == nil
            let toolAccepts = toolErr == nil
            #expect(
                ofAccepts == toolAccepts,
                "Name validation inconsistency for \"\(name)\": OutputFormat \(ofAccepts ? "accepts" : "rejects"), Tool \(toolAccepts ? "accepts" : "rejects")"
            )
        }
    }

    @Test("Property 3: Known valid names are accepted by both OutputFormat and Tool")
    func knownValidNamesAcceptedByBoth() throws {
        let validNames = [
            "a", "Z", "0", "_", "-",
            "valid_name", "valid-name", "ValidName123",
            "a-b_c-d", "ALLCAPS", "lowercase",
            "MiXeD_CaSe-123", "test-schema_v2",
        ]

        for name in validNames {
            #expect(
                outputFormatAccepts(name),
                "OutputFormat should accept valid name \"\(name)\""
            )
            #expect(
                toolAccepts(name),
                "Tool should accept valid name \"\(name)\""
            )
        }
    }

    @Test("Property 3: Empty string is rejected by both OutputFormat and Tool")
    func emptyStringRejectedByBoth() throws {
        #expect(!outputFormatAccepts(""))
        #expect(!toolAccepts(""))

        let ofError = outputFormatError("")
        let toolErr = toolError("")

        #expect(ofError == BedrockLibraryError.invalidName(""))
        #expect(toolErr == BedrockLibraryError.invalidName(""))
    }

    @Test("Property 3: Strings with only invalid characters are rejected by both")
    func invalidOnlyStringsRejectedByBoth() throws {
        let invalidOnlyNames = ["!!!", "@#$", "...", "***", "   ", "~~~", "()", "[]", "{}"]

        for name in invalidOnlyNames {
            #expect(
                !outputFormatAccepts(name),
                "OutputFormat should reject invalid-only name \"\(name)\""
            )
            #expect(
                !toolAccepts(name),
                "Tool should reject invalid-only name \"\(name)\""
            )
        }
    }
}
