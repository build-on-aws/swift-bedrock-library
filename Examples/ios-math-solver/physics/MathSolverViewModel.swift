import BedrockService
import AWSSDKIdentity
import Foundation
import SmithyIdentity
import UIKit

//import ClientRuntime // for SDK Logging

/// ViewModel responsible for handling math problem solving using AWS Bedrock Claude model
final class MathSolverViewModel: ObservableObject, @unchecked Sendable {
    /// The current response being streamed from the model
    @Published var streamedResponse = ""
    /// Indicates whether a request is in progress
    @Published var isLoading = false
    
    /// The Bedrock service (provided by the bedrock library)  used to make API calls
    private var bedrockService: BedrockService?
    
    /// Reference to the authentication manager
    private weak var authManager: AuthenticationManager?
    
    /// Initializes the view model with an optional authentication manager
    /// - Parameter authManager: The authentication manager to use for AWS credentials
    init(authManager: AuthenticationManager? = nil) {
        self.authManager = authManager
        // Don't set up client in init - wait until we have credentials
    }
    
    /// Sets the authentication manager and initializes the Bedrock client
    /// - Parameter authManager: The authentication manager to use for AWS credentials
    func setAuthManager(_ authManager: AuthenticationManager) {
        self.authManager = authManager
        setupBedrockClient()
    }
    
    /// Updates the Bedrock client with the latest credentials
    func updateCredentials() {
        setupBedrockClient()
    }
    
    /// Sets up the Bedrock client with the current authentication credentials
    private func setupBedrockClient() {
        do {
            
            // when modelId starts with "eu", use eu-west-1 region, when it starts with "us", use us-east-1 region
            let region = modelId.starts(with: "eu") ? "eu-north-1" : "us-east-1"
            let config = try BedrockRuntimeClient.BedrockRuntimeClientConfiguration(region: region)
            
            // Use identity resolver from AuthenticationManager if available
            if let authManager = authManager, let identityResolver = authManager.identityResolver {
                config.awsCredentialIdentityResolver = identityResolver
                print("Using web identity credential resolver for Bedrock client")
                bedrockClient = BedrockRuntimeClient(config: config)
            } else {
                print("No credential resolver available. User must sign in first.")
                bedrockClient = nil
            }
        } catch {
            print("Error initializing Bedrock client: \(error)")
            bedrockClient = nil
        }
    }
    
    /// Analyzes a math or physics problem in an image using AWS Bedrock Claude model
    /// - Parameter image: The UIImage containing the math/physics problem to solve
    func analyzeImage(_ image: UIImage) {
        guard let bedrockClient = bedrockClient else {
            print("Bedrock client not initialized. Please sign in first.")
            DispatchQueue.main.async {
                self.isLoading = false
                self.streamedResponse = "Error: Authentication required. Please sign in to use this feature."
            }
            return
        }
        
        isLoading = true
        streamedResponse = ""
        
        // Resize image to ensure it's under 5MB when base64 encoded
        let resizedImage = resizeImageIfNeeded(image)
        
        // Start with high quality and progressively reduce until under limit
        var compressionQuality: CGFloat = 0.9
        var imageData: Data?
        var base64Size = 0
        
        repeat {
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            if let data = imageData {
                // Calculate base64 size (approximately 4/3 of original size)
                base64Size = Int(Double(data.count) * 1.37)
                
                // If still too large, reduce quality and try again
                if base64Size > 5 * 1024 * 1024 { // 5MB
                    compressionQuality -= 0.1
                    print("Image too large (\(ByteCountFormatter.string(fromByteCount: Int64(base64Size), countStyle: .file))), reducing quality to \(compressionQuality)")
                }
            }
        } while base64Size > 5 * 1024 * 1024 && compressionQuality > 0.1
        
        guard let finalImageData = imageData else {
            print("Failed to convert image to data")
            isLoading = false
            return
        }
        
        let base64Size2 = Int(Double(finalImageData.count) * 1.37)
        print("Final image size: \(ByteCountFormatter.string(fromByteCount: Int64(finalImageData.count), countStyle: .file)), estimated base64 size: \(ByteCountFormatter.string(fromByteCount: Int64(base64Size2), countStyle: .file))")
        
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
        let system: BedrockRuntimeClientTypes.SystemContentBlock = .text(systemPrompt)
        
        // Create the user message with text prompt and image
        let userPrompt = "Please solve this math or physics problem. Show all steps and explain the concepts involved."
        let prompt: BedrockRuntimeClientTypes.ContentBlock = .text(userPrompt)
        let image: BedrockRuntimeClientTypes.ContentBlock = .image(.init(format: .jpeg, source: .bytes(finalImageData)))
        
        // Create the user message with both text and image content
        let userMessage = BedrockRuntimeClientTypes.Message(
            content: [prompt, image],
            role: .user
        )
        
        // Initialize the messages array with the user message
        var messages: [BedrockRuntimeClientTypes.Message] = []
        messages.append(userMessage)
        
        // Configure the inference parameters
        let inferenceConfig: BedrockRuntimeClientTypes.InferenceConfiguration = .init(maxTokens: 4096, temperature: 0.0)
        
        // Create the input for the Converse API with streaming
        let input = ConverseStreamInput(inferenceConfig: inferenceConfig, messages: messages, modelId: modelId, system: [system])
        
        // Make the streaming request
        Task {
            do {
                // Process the stream
                let response = try await bedrockClient.converseStream(input: input)
                
                // Process the streaming response
                guard let stream = response.stream else {
                    print("No stream available")
                    return
                }
                
                // Iterate through the stream events
                for try await event in stream {
                    switch event {
                    case .messagestart:
                        print("AI-assistant started to stream")
                        
                    case let .contentblockdelta(deltaEvent):
                        // Handle text content as it arrives
                        if case let .text(text) = deltaEvent.delta {
                            DispatchQueue.main.async {
                                self.streamedResponse += text
                            }
                        }
                        
                    case .messagestop:
                        print("Stream ended")
                        // Create a complete assistant message from the streamed response
                        let assistantMessage = BedrockRuntimeClientTypes.Message(
                            content: [.text(self.streamedResponse)],
                            role: .assistant
                        )
                        messages.append(assistantMessage)
                        
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
        let maxDimension: CGFloat = 2048 // Max dimension in pixels
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
        
        print("Resized image from \(Int(originalSize.width))x\(Int(originalSize.height)) to \(Int(newWidth))x\(Int(newHeight))")
        return resizedImage ?? image
    }
}
