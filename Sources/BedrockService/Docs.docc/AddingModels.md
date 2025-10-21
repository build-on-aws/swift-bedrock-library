# Adding Models

Extend BedrockService with new foundation models

## Overview

BedrockService is designed to be extensible. You can add support for new foundation models by implementing the appropriate modality protocols and creating BedrockModel instances.

## Adding Converse-Only Models

For models that only support the Converse API, use `StandardConverse`:

```swift
extension BedrockModel {
    public static let new_bedrock_model = BedrockModel(
        id: "family.model-id-v1:0",
        name: "New Model Name",
        modality: StandardConverse(
            parameters: ConverseParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.3),
                maxTokens: Parameter(.maxTokens, minValue: 1, maxValue: nil, defaultValue: nil),
                topP: Parameter(.topP, minValue: 0.01, maxValue: 0.99, defaultValue: 0.75),
                stopSequences: StopSequenceParams(maxSequences: nil, defaultValue: []),
                maxPromptSize: nil
            ),
            features: [.textGeneration, .systemPrompts, .document, .toolUse]
        )
    )
}
```

### Converse Features

Specify which features the model supports:

- `.textGeneration` - Basic text generation
- `.systemPrompts` - System message support
- `.vision` - Image input processing
- `.document` - Document input processing
- `.toolUse` - Function calling
- `.streaming` - Real-time response streaming
- `.reasoning` - Reasoning output

## Adding Text Generation Models

For models that need custom InvokeModel support, implement the required protocols:

### Step 1: Create Request/Response Structures

```swift
public struct LlamaRequestBody: BedrockBodyCodable {
    let prompt: String
    let max_gen_len: Int
    let temperature: Double
    let top_p: Double

    public init(prompt: String, maxTokens: Int = 512, temperature: Double = 0.5) {
        self.prompt = "<|begin_of_text|><|start_header_id|>user<|end_header_id|>\(prompt)<|eot_id|><|start_header_id|>assistant<|end_header_id|>"
        self.max_gen_len = maxTokens
        self.temperature = temperature
        self.top_p = 0.9
    }
}

struct LlamaResponseBody: ContainsTextCompletion {
    let generation: String
    let prompt_token_count: Int
    let generation_token_count: Int
    let stop_reason: String

    public func getTextCompletion() throws -> TextCompletion {
        TextCompletion(generation)
    }
}
```

### Step 2: Implement TextModality

```swift
struct LlamaText: TextModality {
    let parameters: TextGenerationParameters

    init(parameters: TextGenerationParameters) {
        self.parameters = parameters
    }

    func getName() -> String { "Llama Text Generation" }

    func getParameters() -> TextGenerationParameters {
        parameters
    }

    func getTextRequestBody(
        prompt: String,
        maxTokens: Int?,
        temperature: Double?,
        topP: Double?,
        topK: Int?,
        stopSequences: [String]?
    ) throws -> BedrockBodyCodable {
        guard topK == nil else {
            throw BedrockLibraryError.notSupported("TopK is not supported for Llama")
        }
        guard stopSequences == nil else {
            throw BedrockLibraryError.notSupported("Stop sequences not supported for Llama")
        }
        
        return LlamaRequestBody(
            prompt: prompt,
            maxTokens: maxTokens ?? parameters.maxTokens.defaultValue,
            temperature: temperature ?? parameters.temperature.defaultValue
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        let decoder = JSONDecoder()
        return try decoder.decode(LlamaResponseBody.self, from: data)
    }
}
```

### Step 3: Create BedrockModel Instance

```swift
extension BedrockModel {
    public static let llama3_3_70b_instruct: BedrockModel = BedrockModel(
        id: "meta.llama3-3-70b-instruct-v1:0",
        name: "Llama 3.3 70B Instruct",
        modality: LlamaText(
            parameters: TextGenerationParameters(
                temperature: Parameter(.temperature, minValue: 0, maxValue: 1, defaultValue: 0.5),
                maxTokens: Parameter(.maxTokens, minValue: 0, maxValue: 2_048, defaultValue: 512),
                topP: Parameter(.topP, minValue: 0, maxValue: 1, defaultValue: 0.9),
                topK: Parameter.notSupported(.topK),
                stopSequences: StopSequenceParams.notSupported(),
                maxPromptSize: nil
            )
        )
    )
}
```

## Adding Image Generation Models

For image generation models, implement `ImageModality`:

### Step 1: Create Request/Response Structures

```swift
public struct AmazonImageRequestBody: BedrockBodyCodable {
    let taskType: TaskType
    private let textToImageParams: TextToImageParams?
    private let imageGenerationConfig: ImageGenerationConfig

    public static func textToImage(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) -> Self {
        // Implementation details...
    }
}

struct AmazonImageResponseBody: ContainsImageGeneration {
    let images: [String]
    
    func getImageGenerationOutput() throws -> ImageGenerationOutput {
        ImageGenerationOutput(images: images)
    }
}
```

### Step 2: Implement ImageModality

```swift
struct AmazonImage: ImageModality {
    let parameters: ImageGenerationParameters
    
    func getName() -> String { "Amazon Image Generation" }
    
    func getImageGenerationParameters() -> ImageGenerationParameters {
        parameters
    }
    
    func hasTextToImageModality() -> Bool { true }
    func hasImageVariationModality() -> Bool { false }
    
    func getTextToImageRequestBody(/* parameters */) throws -> BedrockBodyCodable {
        // Implementation...
    }
    
    func getImageResponseBody(from data: Data) throws -> ContainsImageGeneration {
        let decoder = JSONDecoder()
        return try decoder.decode(AmazonImageResponseBody.self, from: data)
    }
}
```

## Hybrid Modalities

For models supporting multiple capabilities, create custom modalities:

```swift
struct ModelFamilyModality: TextModality, ConverseModality {
    let parameters: TextGenerationParameters
    let converseFeatures: [ConverseFeature]
    let converseParameters: ConverseParameters

    init(parameters: TextGenerationParameters, features: [ConverseFeature] = [.textGeneration]) {
        self.parameters = parameters
        self.converseFeatures = features
        self.converseParameters = ConverseParameters(textGenerationParameters: parameters)
    }

    func getName() -> String { "Model Family Text and Converse" }

    // Implement TextModality methods
    func getParameters() -> TextGenerationParameters { parameters }
    func getTextRequestBody(/* ... */) throws -> BedrockBodyCodable { /* ... */ }
    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion { /* ... */ }

    // Implement ConverseModality methods
    func getConverseParameters() -> ConverseParameters { converseParameters }
    func getConverseFeatures() -> [ConverseFeature] { converseFeatures }
}
```

## Parameter Validation

Define parameter constraints carefully:

```swift
// Supported parameter with range
Parameter(.temperature, minValue: 0.0, maxValue: 2.0, defaultValue: 1.0)

// Supported parameter with no upper limit
Parameter(.maxTokens, minValue: 1, maxValue: nil, defaultValue: 1000)

// Unsupported parameter
Parameter.notSupported(.topK)

// Stop sequences with limits
StopSequenceParams(maxSequences: 4, defaultValue: [])

// Stop sequences not supported
StopSequenceParams.notSupported()
```

## Testing New Models

Test your model implementation:

```swift
func testNewModel() async throws {
    let bedrock = try await BedrockService()
    let model = BedrockModel.new_bedrock_model
    
    // Test basic functionality
    if model.hasTextModality() {
        let completion = try await bedrock.completeText("Hello", with: model)
        print("Text completion: \(completion.completion)")
    }
    
    if model.hasConverseModality() {
        let builder = try ConverseRequestBuilder(with: model)
            .withPrompt("Hello")
        let reply = try await bedrock.converse(with: builder)
        print("Converse reply: \(reply)")
    }
    
    // Test parameter validation
    do {
        let _ = try await bedrock.completeText(
            "Test", 
            with: model, 
            temperature: 5.0 // Should fail if max is < 5.0
        )
    } catch BedrockServiceError.parameterOutOfRange(let param, let value, let range) {
        print("Expected parameter error: \(param) = \(value) not in \(range)")
    }
}
```

## Best Practices

1. **Follow AWS Documentation**: Check the official model documentation for exact request/response formats
2. **Validate Parameters**: Implement proper parameter validation based on model capabilities
3. **Handle Errors**: Provide clear error messages for unsupported features
4. **Test Thoroughly**: Test all supported features and parameter combinations
5. **Document Limitations**: Clearly document what features are and aren't supported

## See Also

- [AWS Bedrock Model Parameters](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters.html)
- [Converse API Supported Features](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-supported-models-features.html)