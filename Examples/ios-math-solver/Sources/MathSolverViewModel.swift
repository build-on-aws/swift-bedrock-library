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

import BedrockService
import Foundation
import Logging
import UIKit

/// ViewModel responsible for handling math problem solving using AWS Bedrock Claude model
final class MathSolverViewModel: ObservableObject, @unchecked Sendable {
    /// The current response being streamed from the model
    @Published var streamedResponse = ""
    /// Indicates whether a request is in progress
    @Published var isLoading = false

    /// The Bedrock service (provided by the bedrock library)  used to make API calls
    private var bedrockService: BedrockService?
    private let model: BedrockModel = .claude_sonnet_v4
    private let region: Region = .useast1

    /// Reference to the authentication manager
    private weak var authManager: AuthenticationManager?

    // to integrate with Sign In With Apple (SIWA), you must prepare your AWS account
    // Follow instructions at https://docs.aws.amazon.com/sdk-for-swift/latest/developer-guide/apple-integration.html#apple-sign-in

    private let awsAccountNumber = "486652066693"  // TODO: Replace with your AWS account number
    private let awsIAMRoleName = "ios-swift-bedrock"  // TODO: Replace with your IAM role name
    private var logger = Logger(label: "MathSolverViewModel")

    /// Sets the authentication manager and initializes the Bedrock client
    /// - Parameter authManager: The authentication manager to use for AWS credentials
    func setAuthManager(_ authManager: AuthenticationManager) async {
        self.authManager = authManager
        logger.logLevel = .trace
        await setupBedrockClient()
    }

    /// Sets up the Bedrock client with the current authentication credentials
    private func setupBedrockClient() async {
        do {
            // Use identity resolver from AuthenticationManager if available
            if let authManager = authManager, let token = authManager.jwtToken {
                bedrockService = try await BedrockService(
                    region: region,
                    logger: logger,
                    authentication: .webIdentity(
                        token: token,
                        roleARN: "arn:aws:iam::\(awsAccountNumber):role/\(awsIAMRoleName)",
                        region: region
                    )
                )
                print("Using web identity credential resolver for Bedrock")
            } else {
                print("No credential resolver available. User must sign in first.")
                bedrockService = nil
            }
        } catch {
            print("Error initializing Bedrock client: \(error)")
            bedrockService = nil
        }
    }

    /// Analyzes a math or physics problem in an image using AWS Bedrock Claude model
    /// - Parameter image: The UIImage containing the math/physics problem to solve
    func analyzeImage(_ image: UIImage) {
        guard let bedrockService = bedrockService else {
            print("Bedrock client not initialized. Please sign in first.")
            DispatchQueue.main.async {
                self.isLoading = false
                self.streamedResponse = "Error: Authentication required. Please sign in to use this feature."
            }
            return
        }

        isLoading = true
        streamedResponse = ""

        // Define the system prompt that instructs Claude how to respond
        let systemPrompt = """
            You are a math and physics tutor. Your task is to:
            1. Read and understand the math or physics problem in the image
            2. Provide a clear, step-by-step solution to the problem
            3. Briefly explain any relevant concepts used in solving the problem
            4. Be precise and accurate in your calculations
            5. Use mathematical notation when appropriate

            Format your response with clear section headings and numbered steps.
            Reply in the same language as the one used in the image.
            """

        // Create the user message with text prompt and image
        guard let finalImageAsData = adjustImageSizeAndCompression(image: image),
            let promptBuilder = try? ConverseRequestBuilder(with: model)
                .withPrompt(
                    "Please solve this math or physics problem. Show all steps and explain the concepts involved."
                )
                .withSystemPrompt(systemPrompt)
                .withImage(format: .jpeg, source: finalImageAsData)
                .withMaxTokens(4096)
                .withTemperature(0.0)
        else {
            print("Failed to create ConverseRequestBuilder")
            return
        }

        // Make the streaming request
        Task {
            var messages: [Message] = []
            do {
                // Process the stream
                let response = try await bedrockService.converseStream(with: promptBuilder)

                // Iterate through the stream events
                for try await event in response.stream {
                    switch event {
                    case .messageStart(let role):
                        print("Message stream started with role: \(role)")

                    case .text(_, let text):
                        // Handle text content as it arrives
                        DispatchQueue.main.async {
                            self.streamedResponse += text
                        }

                    case .messageComplete(let message):
                        print("Stream ended")
                        messages.append(message)

                    default:
                        break
                    }
                }

                DispatchQueue.main.async {
                    self.isLoading = false
                    print(self.streamedResponse)
                    print("Streaming completed. Final response length: \(self.streamedResponse.count)")
                }
            } catch {
                print("Error in streaming response: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.streamedResponse = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    /// Resizes an image if it exceeds the maximum allowed dimensions
    /// - Parameter image: The original UIImage to resize
    /// - Returns: A resized UIImage if the original was too large, otherwise the original image
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let maxDimension: CGFloat = 2048  // Max dimension in pixels
        let scale = image.scale
        let originalSize = image.size

        // Calculate scale factor to reduce image size
        let scaleFactor = min(maxDimension / originalSize.width, maxDimension / originalSize.height)

        // If image is already smaller than maxDimension, return original
        if scaleFactor >= 1 {
            return image
        }

        // Calculate new size
        let newWidth = originalSize.width * scaleFactor
        let newHeight = originalSize.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)

        // Create new image
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        print(
            "Resized image from \(Int(originalSize.width))x\(Int(originalSize.height)) to \(Int(newWidth))x\(Int(newHeight))"
        )
        return resizedImage ?? image
    }

    /// Adjusts the image size and compression to ensure it fits within the 5MB base64 limit
    /// - Parameter image: The UIImage to adjust
    /// - Returns: The adjusted image data as Data, or nil if it could not be converted
    private func adjustImageSizeAndCompression(image: UIImage) -> Data? {
        // Compress image to ensure it's under 5MB when base64 encoded
        let resizedImage = resizeImageIfNeeded(image)

        // Start with high quality and progressively reduce quality until under limit
        var compressionQuality: CGFloat = 0.9
        var imageData: Data?
        var base64Size = 0
        let maxBase64Size = 5 * 1024 * 1024  // 5MB in bytes

        repeat {
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            if let data = imageData {
                // Calculate base64 size (approximately 4/3 of original size)
                base64Size = Int(Double(data.count) * 1.37)

                // If still too large, reduce quality and try again
                if base64Size > maxBase64Size {
                    compressionQuality -= 0.1
                    print(
                        "Image too large (\(ByteCountFormatter.string(fromByteCount: Int64(base64Size), countStyle: .file))), reducing quality to \(compressionQuality)"
                    )
                }
            }
        } while base64Size > maxBase64Size && compressionQuality > 0.1

        guard let finalImageData = imageData else {
            print("Failed to convert image to data")
            isLoading = false
            return nil
        }

        let base64Size2 = Int(Double(finalImageData.count) * 1.37)
        print(
            "Final image size: \(ByteCountFormatter.string(fromByteCount: Int64(finalImageData.count), countStyle: .file)), estimated base64 size: \(ByteCountFormatter.string(fromByteCount: Int64(base64Size2), countStyle: .file))"
        )

        return finalImageData
    }
}
