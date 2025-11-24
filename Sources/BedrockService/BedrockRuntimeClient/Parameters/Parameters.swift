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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A protocol that defines the base requirements for model parameter configurations.
///
/// Types conforming to `Parameters` represent configuration parameters for Amazon Bedrock models,
/// ensuring they are thread-safe, hashable, and equatable for use in concurrent environments.
public protocol Parameters: Sendable, Hashable, Equatable {}

/// A generic parameter definition for numeric model configuration values.
///
/// `Parameter` encapsulates validation rules and metadata for numeric parameters used in Amazon Bedrock models,
/// including minimum and maximum bounds, default values, and support status.
///
/// - Parameters:
///   - T: The numeric type of the parameter value, which must be `Sendable`, `Hashable`, `Equatable`, `Numeric`, and `Comparable`.
public struct Parameter<T: Sendable & Hashable & Equatable & Numeric & Comparable>: Sendable, Hashable, Equatable {
    /// The minimum allowed value for this parameter, if any.
    public let minValue: T?
    /// The maximum allowed value for this parameter, if any.
    public let maxValue: T?
    /// The default value for this parameter, if any.
    public let defaultValue: T?
    /// Indicates whether this parameter is supported by the model.
    public let isSupported: Bool
    /// The name identifier for this parameter.
    public let name: ParameterName

    /// Creates a supported parameter with optional validation bounds and default value.
    ///
    /// - Parameters:
    ///   - name: The parameter name identifier.
    ///   - minValue: The minimum allowed value. Defaults to `nil` (no minimum).
    ///   - maxValue: The maximum allowed value. Defaults to `nil` (no maximum).
    ///   - defaultValue: The default value. Defaults to `nil` (no default).
    public init(_ name: ParameterName, minValue: T? = nil, maxValue: T? = nil, defaultValue: T? = nil) {
        self = Self(name: name, minValue: minValue, maxValue: maxValue, defaultValue: defaultValue, isSupported: true)
    }

    /// Creates an unsupported parameter marker.
    ///
    /// Use this factory method to indicate that a parameter is not supported by a particular model.
    ///
    /// - Parameter name: The parameter name identifier.
    /// - Returns: A parameter instance marked as unsupported.
    public static func notSupported(_ name: ParameterName) -> Self {
        Self(name: name, minValue: nil, maxValue: nil, defaultValue: nil, isSupported: false)
    }

    private init(name: ParameterName, minValue: T? = nil, maxValue: T? = nil, defaultValue: T? = nil, isSupported: Bool)
    {
        self.minValue = minValue
        self.maxValue = maxValue
        self.defaultValue = defaultValue
        self.isSupported = isSupported
        self.name = name
    }

    /// Validates that a value meets the parameter's constraints.
    ///
    /// This method checks whether the parameter is supported and whether the value falls within
    /// the defined minimum and maximum bounds.
    ///
    /// - Parameter value: The value to validate.
    /// - Throws: `BedrockLibraryError.notSupported` if the parameter is not supported,
    ///           or `BedrockLibraryError.invalidParameter` if the value is out of bounds.
    public func validateValue(_ value: T) throws {
        guard isSupported else {
            throw BedrockLibraryError.notSupported("Parameter \(name) is not supported.")
        }
        if let minValue = minValue {
            guard value >= minValue else {
                throw BedrockLibraryError.invalidParameter(
                    name,
                    "Parameter \(name) should be at least \(minValue). Value: \(value)"
                )
            }
        }
        if let maxValue = maxValue {
            guard value <= maxValue else {
                throw BedrockLibraryError.invalidParameter(
                    name,
                    "Parameter \(name) should be at most \(maxValue). Value: \(value)"
                )
            }
        }
    }
}

extension String {
    func trimWhitespaceAndNewlines() -> String {
        let scalars = self.unicodeScalars
        let whitespaceAndNewline: (UnicodeScalar) -> Bool = { $0.properties.isWhitespace || $0 == "\n" || $0 == "\r" }

        // Find start
        var startIdx = scalars.startIndex
        while startIdx < scalars.endIndex, whitespaceAndNewline(scalars[startIdx]) {
            startIdx = scalars.index(after: startIdx)
        }
        // Find end
        var endIdx = scalars.endIndex
        while endIdx > startIdx, whitespaceAndNewline(scalars[scalars.index(before: endIdx)]) {
            endIdx = scalars.index(before: endIdx)
        }
        return String(scalars[startIdx..<endIdx])
    }
}

/// Parameters for validating prompt text input.
///
/// `PromptParams` defines constraints for prompt strings, including maximum size validation
/// and empty string checks.
public struct PromptParams: Parameters {
    /// The maximum allowed size for the prompt in UTF-8 bytes, if any.
    public let maxSize: Int?

    /// Validates that a prompt string meets the defined constraints.
    ///
    /// This method ensures the prompt is not empty (after trimming whitespace) and does not exceed
    /// the maximum size limit if one is defined.
    ///
    /// - Parameter value: The prompt string to validate.
    /// - Throws: `BedrockLibraryError.invalidPrompt` if the prompt is empty or exceeds the maximum size.
    public func validateValue(_ value: String) throws {
        guard !value.trimWhitespaceAndNewlines().isEmpty else {
            throw BedrockLibraryError.invalidPrompt("Prompt is not allowed to be empty.")
        }
        if let maxSize {
            let length = value.utf8.count
            guard length <= maxSize else {
                throw BedrockLibraryError.invalidPrompt(
                    "Prompt is not allowed to be longer than \(maxSize) tokens. Prompt lengt \(length)"
                )
            }
        }
    }
}

/// Parameters for validating stop sequences in model generation.
///
/// `StopSequenceParams` defines constraints for stop sequence arrays, including the maximum number
/// of sequences allowed, default values, and support status.
public struct StopSequenceParams: Parameters {
    /// The maximum number of stop sequences allowed, if any.
    public let maxSequences: Int?
    /// The default stop sequences to use, if any.
    public let defaultValue: [String]?
    /// Indicates whether stop sequences are supported by the model.
    public let isSupported: Bool

    /// Creates supported stop sequence parameters with optional constraints and defaults.
    ///
    /// - Parameters:
    ///   - maxSequences: The maximum number of stop sequences allowed. Defaults to `nil` (no limit).
    ///   - defaultValue: The default stop sequences. Defaults to `nil` (no defaults).
    public init(maxSequences: Int? = nil, defaultValue: [String]? = nil) {
        self = Self(maxSequences: maxSequences, defaultValue: defaultValue, isSupported: true)
    }

    /// Creates an unsupported stop sequence parameters marker.
    ///
    /// Use this factory method to indicate that stop sequences are not supported by a particular model.
    ///
    /// - Returns: A stop sequence parameters instance marked as unsupported.
    public static func notSupported() -> Self {
        Self(maxSequences: nil, defaultValue: nil, isSupported: false)
    }

    private init(maxSequences: Int? = nil, defaultValue: [String]? = nil, isSupported: Bool = true) {
        self.maxSequences = maxSequences
        self.defaultValue = defaultValue
        self.isSupported = isSupported
    }

    /// Validates that a stop sequence array meets the defined constraints.
    ///
    /// This method checks whether the number of stop sequences exceeds the maximum allowed.
    ///
    /// - Parameter value: The array of stop sequences to validate.
    /// - Throws: `BedrockLibraryError.invalidStopSequences` if the number of sequences exceeds the maximum.
    public func validateValue(_ value: [String]) throws {
        if let maxSequences {
            guard value.count <= maxSequences else {
                throw BedrockLibraryError.invalidStopSequences(
                    value,
                    "You can only provide up to \(maxSequences) stop sequences. Number of stop sequences: \(value.count)"
                )
            }
        }
    }
}

// MARK: - Support for Service Tier
// https://docs.aws.amazon.com/bedrock/latest/userguide/service-tiers-inference.html

/// Service tier options for Amazon Bedrock inference requests.
///
/// Service tiers allow you to control the priority and cost of your inference requests.
/// Different tiers provide different latency guarantees and pricing models.
///
/// For more information, see [Service Tiers](https://docs.aws.amazon.com/bedrock/latest/userguide/service-tiers-inference.html).
public enum ServiceTier: String, Codable, Sendable {
    /// Standard service tier with balanced performance and cost.
    case `default`
    /// Priority service tier for low-latency, high-priority workloads.
    case priority
    /// Flexible service tier optimized for cost-sensitive, non-time-critical workloads.
    case flex
}
