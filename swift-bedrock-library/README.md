# BedrockService

This library is a work in progress, feel free to open an issue, but do not use it in your projects just yet. 

## Getting started with BedrockService

1. Set-up your `Package.swift`

First add dependencies: 
```bash
swift package add-dependency https://github.com/sebsto/swift-bedrock-library.git --branch main
swift package add-target-dependency BedrockService TargetName --package swift-bedrock-library
```

Next up add `platforms` configuration after `name`

```swift
platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
```

Your `Package.swift` should now look something like this: 
```swift
import PackageDescription

let package = Package(
    name: "ProjectName",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    dependencies: [
        .package(url: "https://github.com/sebsto/swift-bedrock-library.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "TargetName",
            dependencies: [
                .product(name: "BedrockService", package: "swift-bedrock-library"),
            ]
        )
    ]
)
```

2. Import the BedrockService and BedrockTypes

```swift 
import BedrockService
import BedrockTypes
```

3. Initialize the BedrockService

Choose what Region to use, whether to use AWS SSO authentication instead of standard credentials and pass a logger. If no region is passed it will default to `.useast1`, if no logger is provided a default logger with the name `bedrock.service` is created. The log level will be set to the environment variable `BEDROCK_SERVICE_LOG_LEVEL` or default to `.trace`. Choose the form of authentication you wish to use.

```swift 
let bedrock = try await BedrockService(
    region: .uswest1,
    logger: logger,
    authentication: .sso
) 
```

4. List the available models

Use the `listModels()` function to test your set-up. This function will return an array of `ModelSummary` objects, each one representing a model supported by Amazon Bedrock. The ModelSummaries that contain a `BedrockModel` object are the models supported by BedrockService. 

```swift
let models = try await bedrock.listModels()
```


## Chatting using the Converse or ConverseStream API

### Text prompt

To sent a text prompt to a model, first choose a model that supports converse, you can verify this by using the `hasConverseModality` function on the `BedrockModel`. Then use the model to create a `ConverseRequestBuilder`, add your prompt to it with the `.withPormpt` function. Use the builder to sent your request to the Converse API with the `converse` function. You can then easily print the reply and use it to create a new builder with the same model and inference parameters but with an updated history.

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality() else {
    throw MyError.incorrectModality("\(model.name) does not support converse")
}

var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Tell me about rainbows")

var reply = try await bedrock.converse(with: builder)

print("Assistant: \(reply)")

builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Do you think birds can see them too?")

reply = try await bedrock.converse(with: builder)

print("Assistant: \(reply)")
```

Optionally add inference parameters. Note that the builder can be used to create the next builder with the same parameters and the updated history.

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Tell me about rainbows")
    .withMaxTokens(512)
    .withTemperature(0.2)
    .withStopSequences(["END", "STOP", "<assistant>"])
    .withSystemPrompts(["Do not pretend to be human", "Never talk about goats", "You like puppies"])

var reply = try await bedrock.converse(with: builder)

builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Do you think birds can see them too?")

reply = try await bedrock.converse(with: builder)
```

To get a streaming response, use the same `ConverseRequestBuilder`, but the `converseStream` function instead of the `converse` function. Ensure the model you are using supports streaming. 
The stream will contain `ConverseStreamElement` object that can either be `contentSegment` containing a piece of content, `contentComplete` signifying that a `Content` object is complete or a `messageComplete` to return the final completed message with all the complete content parts. A `contentSegment` could either be `text`, `toolUse`, `reasoning` or `encryptedReasoning`.

To create the next builder, with the same model and inference parameters, use the full message from the `.messageComplete`.

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality() else {
    throw MyError.incorrectModality("\(model.name) does not support converse")
}
guard model.hasConverseModality(.reasoning) else {
    throw MyError.incorrectModality("\(model.name) does not support reasoning")
}

var builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Tell me more about the birds in Paris")

let stream = try await bedrock.converseStream(with: builder)

for try await element in stream {
    switch element {
    case .contentSegment(let contentSegment):
        switch contentSegment {
        case .text(_, let text):
            print(text, terminator: "")
        default:
            break
        }
    case .contentBlockComplete:
        print("\n\n")
    case .messageComplete(let message):
        assistantMessage = message
    }
}

builder = try ConverseRequestBuilder(from: builder, with: assistantMessage)
    .withPrompt("And what about the rats?")
```

### Vision

To sent an image to a model, first ensure the model suports vision. Next simply add the image to the `ConverseRequestBuilder` with the `withImage` function. The function can either take an `ImageBlock` object or the format and bytes to construct the object.


```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality(.vision) else {
    throw MyError.incorrectModality("\(model.name) does not support converse vision")
}

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you tell me about this plant?")
    .withImage(format: .jpeg, source: base64EncodedImage)

let reply = try await bedrock.converse(with: builder)

print("Assistant: \(reply)")
```

Optionally add inference parameters. 

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you tell me about this plant?")
    .withImage(format: .jpeg, source: base64EncodedImage)
    .withTemperature(0.8)

let reply = try await bedrock.converse(with: builder)
```

Note that the builder can be used to create the next builder with the same parameters and the updated history.

```swift
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you tell me about this plant?")
    .withImage(format: .jpeg, source: base64EncodedImage)
    .withTemperature(0.8)

var reply = try await bedrock.converse(with: builder)

builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Where can I find those plants?")

reply = try await bedrock.converse(with: builder)
```

To use streaming use the exact same `ConverseRequestBuilder`, but use the `converseStream` function instead of the `converse` function. An example is given in the [text prompt section](#text-prompt).

### Document

To sent an document to a model, first ensure the model suports document. Next simply add the image to the `ConverseRequestBuilder` with the `withDocument` function. The function can either take an `DocumentBlock` object or the name, format and bytes to construct the object.

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality(.document) else {
    throw MyError.incorrectModality("\(model.name) does not support converse document")
}

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you give me a summary of this chapter?")
    .withDocument(name: "Chapter 1", format: .pdf, source: base64EncodedDocument)

let reply = try await bedrock.converse(with: builder)

print("Assistant: \(reply)")
```

Optionally add inference parameters. 

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you give me a summary of this chapter?")
    .withDocument(name: "Chapter 1", format: .pdf, source: base64EncodedDocument)
    .withMaxTokens(512)
    .withTemperature(0.4)

var reply = try await bedrock.converse(with: builder)
```

Note that the builder can be used to create the next builder with the same parameters and the updated history.

```swift
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you give me a summary of this chapter?")
    .withDocument(name: "Chapter 1", format: .pdf, source: base64EncodedDocument)
    .withMaxTokens(512)
    .withTemperature(0.4)

var reply = try await bedrock.converse(with: builder)

builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Thanks, can you make a Dutch version as well?")

reply = try await bedrock.converse(with: builder)
```

To use streaming use the exact same `ConverseRequestBuilder`, but use the `converseStream` function instead of the `converse` function. An example is given in the [text prompt section](#text-prompt).

### Tools

For tool usage, first ensure the model supports the use of tools. Next define at least one `Tool` and add it to the `ConverseRequestBuilder` with the `withTool` function (or the `withTools` function to add several tools at once). After sending a request the model could now sent back a `ToolUse` asking for specific information from a specific tool. Use this to sent the information back in a `ToolResult`, by using the `withToolResult` function. You will now receive a reply informed by the result from the tool.


```swift
let model: BedrockModel = .nova_lite

// verify that the model supports tool usage
guard model.hasConverseModality(.toolUse) else {
    throw MyError.incorrectModality("\(model.name) does not support converse tools")
}

// define the inputschema for your tool
let inputSchema = JSON([
    "type": "object",
    "properties": [
        "sign": [
            "type": "string",
            "description": "The call sign for the radio station for which you want the most popular song. Example calls signs are WZPZ and WKRP."
        ]
    ],
    "required": [
        "sign"
    ]
])

// create a Tool object
let tool = try Tool(name: "top_song", inputSchema: inputSchema, description: "Get the most popular song played on a radio station.")

// create a ConverseRequestBuilder with a prompt and the Tool object
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("What is the most popular song on WZPZ?")
    .withTool(tool)

// pass the ConverseRequestBuilder object to the converse function
var reply = try await bedrock.converse(with: builder)

if let toolUse = try? reply.getToolUse() {
    let id = toolUse.id
    let name = toolUse.name
    let input = toolUse.input

    // ... Logic to use the tool here ... 

    // Send the toolResult back to the model
    builder = try ConverseRequestBuilder(from: builder, with: reply)
        .withToolResult("The Best Song Ever") // pass any Codable or Data
    
    reply = try await bedrock.converse(with: builder)
}

print("Assistant: \(reply)")
// The final reply will be similar to: "The most popular song currently played on WZPZ is \"The Best Song Ever\". If you need more information or have another request, feel free to ask!"
```

To use streaming use the exact same `ConverseRequestBuilder`, but use the `converseStream` function instead of the `converse` function.

```swift
let bedrock = try await BedrockService(authentication: .sso())
let model: BedrockModel = .claudev3_7_sonnet

// define the inputschema for your tool
let schema = JSON(with: [
    "type": "object",
    "properties": [
        "sign": [
            "type": "string",
            "description":
                "The call sign for the radio station for which you want the most popular song. Example calls signs are WZPZ, StuBru and Klara.",
        ]
    ],
    "required": [
        "sign"
    ],
])

// pass a prompt and the tool to converse
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Introduce yourself and mention the tools you have access to?")
    .withTool(
        name: "top_song",
        inputSchema: schema,
        description: "Get the most popular song played on a radio station."
    )

var stream: AsyncThrowingStream<ConverseStreamElement, any Error>
var assistantMessage: Message = Message("empty")

// start a loop to interact with the user
while true {
    var prompt: String = ""
    var indexes: [Int] = []
    var toolRequests: [ToolUseBlock] = []

    // create the stream by calling the converseStream function
    stream = try await bedrock.converseStream(with: builder)

    // process the stream
    for try await element in stream {
        switch element {
        case .contentSegment(let contentSegment):
            switch contentSegment {
            case .text(let index, let text):
                if !indexes.contains(index) {
                    indexes.append(index)
                    print("\nAssistant: ")
                }
                print(text, terminator: "")
            default:
                break
            }
        case .contentBlockComplete(_, let content):
            print("\n")
            if case .toolUse(let toolUse) = content {
                toolRequests.append(toolUse)
            }
        case .messageComplete(let message):
            assistantMessage = message
        }
    }

    // if a request to use a tool was made by the model, use the information in the input to return the correct information back to the model in a ToolResultBlock
    if !toolRequests.isEmpty {
        for toolUse in toolRequests {
            print("found tool use")
            print(toolUse)
            if toolUse.name == "top_song" {
                let sign: String? = toolUse.input["sign"]
                if let sign {
                    let song = try await getMostPopularSong(sign: sign)
                    builder = try ConverseRequestBuilder(from: builder, with: assistantMessage)
                        .withToolResult(song)
                }
            }
        }
    } else { 
        // if no request to use a tool was made, no ToolResultBlock needs to be returned and the user can ask the next question
        print("\nYou: ")
        prompt = readLine()!
        if prompt == "done" {
            break
        }

        builder = try ConverseRequestBuilder(from: builder, with: assistantMessage)
            .withPrompt(prompt)
    }
}
```

### Reasoning

To not only get a text reply but to also follow the models reasoning, enable reasoning by using the `withReasoning` and optionally set the maximum lenght of the reasoning with `withMaxReasoningTokens`. These functions can be combined using the `withReasoning(maxReasoningTokens: Int)` function.

```swift
let model: BedrockModel = .claudev3_7_sonnet

guard model.hasConverseModality() else {
    throw MyError.incorrectModality("\(model.name) does not support converse")
}
guard model.hasConverseModality(.reasoning) else {
    throw MyError.incorrectModality("\(model.name) does not support reasoning")
}

var prompt = "Introduce yourself in one sentence"

var builder = try ConverseRequestBuilder(with: model)
    .withPrompt(prompt)
    .withReasoning()
    .withMaxReasoningTokens(1024)  // Optional

var reply = try await bedrock.converse(with: builder)

if let reasoning = try? reply.getReasoningBlock() {
    print("\nReasoning: \(reasoning.reasoning)")
}
print("\nAssistant: \(reply)")
```

To combine reasoning and streaming, use the same `ConverseRequestBuilder`, but use the `converseStream` function instead of the `converse`function. A `ContentSegment` can then contain `reasoning`.

```swift
let model: BedrockModel = .claudev3_7_sonnet

guard model.hasConverseModality() else {
    throw MyError.incorrectModality("\(model.name) does not support converse")
}
guard model.hasConverseModality(.streaming) else {
    throw MyError.incorrectModality("\(model.name) does not support streaming")
}
guard model.hasConverseModality(.reasoning) else {
    throw MyError.incorrectModality("\(model.name) does not support reasoning")
}

var builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("Tell me more about the birds in Paris")
    .withReasoning(maxReasoningTokens: 1024)

let stream = try await bedrock.converseStream(with: builder)

var indexes: [Int] = []

for try await element in stream {
    switch element {
    case .contentSegment(let contentSegment):
        switch contentSegment {
        case .text(let index, let text):
            if !indexes.contains(index) {
                indexes.append(index)
                print("\nAssistant: ")
            }
            print(text, terminator: "")
        case .reasoning(let index, let text, _):
            if !indexes.contains(index) {
                indexes.append(index)
                print("\nReasoning: ")
            }
            print(text, terminator: "")
        default:
            break
        }
    case .contentBlockComplete:
        print("\n\n")
    case .messageComplete(let message):
        assistantMessage = message
    }
}

builder = try ConverseRequestBuilder(from: builder, with: assistantMessage)
    .withPrompt("And what about the rats?")
```

### Make your own `Message`

Alternatively use the `converse` function that does not take a `prompt`, `toolResult` or `image` and construct the `Message` yourself. 

```swift
// Message with prompt
let replyMessage = try await bedrock.converse(
    with: model,
    conversation: [Message("What day of the week is it?")]
)

// Optionally add inference parameters
let replyMessage = try await bedrock.converse(
    with: model,
    conversation: [Message("What day of the week is it?")],
    maxTokens: 512,
    temperature: 1,
    topP: 0.8,
    stopSequences: ["THE END"],
    systemPrompts: ["Today is Wednesday, make sure to mention that."]
)

// Message with an image and prompt
let replyMessage = try await bedrock.converse(
    with: model,
    conversation: [Message("What is in the this teacup?", imageFormat: .jpeg, imageBytes: base64EncodedImage)],
)

// Message with toolResult
let replyMessage = try await bedrock.converse(
    with: model,
    conversation: [Message(toolResult)],
    tools: [toolA, toolB]
)
```

### JSON

The `JSON` struct is a lightweight and flexible wrapper for working with JSON-like data in Swift. It provides convenient methods and initializers to parse, access, and manipulate JSON data while maintaining type safety and versatility.

#### Creating a JSON Object

You can create a `JSON` object by wrapping raw values or constructing nested structures:
```swift
let json = JSON([
    "name": JSON("Jane Doe"),
    "age": JSON(30),
    "isMember": JSON(true),
])
```
#### Creating JSON object from String

The `JSON` struct provides an initializer to parse valid JSON strings into a `JSON` object:

```swift
let validJSONString = """
{
    "name": "Jane Doe",
    "age": 30,
    "isMember": true
}
"""

do {
    let json = try JSON(from: validJSONString)
    print(json.getValue("name") ?? "No name") // Output: Jane Doe
} catch {
    print("Failed to parse JSON:", error)
}
```

#### Accessing values using `getValue`

The `getValue(_ key: String)` method retrieves values of the specified type from the JSON object:

```swift
if let name: String? = json.getValue("name") {
    print("Name:", name) // Output: Name: Jane Doe
}

if let age: Int? = json.getValue("age") {
    print("Age:", age) // Output: Age: 30
}

if let isMember: Bool? = json.getValue("isMember") {
    print("Is Member:", isMember) // Output: Is Member: true
}
```

#### Accessing values using subscripts

You can also access values dynamically using subscripts:

```swift
let name: String? = json["name"]
print("Name:", name ?? "Unknown") // Output: Name: Jane Doe

let nonExistent: String? = json["nonExistentKey"]
print(nonExistent == nil) // Output: true
```

Note that the subscript methods is also able to handle nested objects.

```swift
let json = JSON([
    "name": JSON("Jane Doe"),
    "age": JSON(30),
    "isMember": JSON(true),
    "address": JSON([
        "street": JSON("123 Main St"),
        "city": JSON("Anytown"),
        "postalCode": JSON(12345),
    ]),
])

let street: String = json["address"]?["street"]
print("Street:", name ?? "Unknown") // Street: 123 Main St
```

## Generating an image using the InvokeModel API

Choose a BedrockModel that supports image generation - you can verify this using the `hasImageModality` and the `hasTextToImageModality` function. The `generateImage` function allows you to create images from text descriptions with various optional parameters:

- `prompt`: Text description of the desired image
- `negativePrompt`: Text describing what to avoid in the generated image
- `nrOfImages`: Number of images to generate
- `cfgScale`: Classifier free guidance scale to control how closely the image follows the prompt
- `seed`: Seed for reproducible image generation
- `quality`: Parameter to control the quality of generated images
- `resolution`: Desired image resolution for the generated images

The function returns an ImageGenerationOutput object containing an array of generated images in base64 format.

```swift
let model: BedrockModel = .nova_canvas

guard model.hasImageModality(),
      model.hasTextToImageModality() else {
    throw MyError.incorrectModality("\(model.name) does not support image generation")
}

let imageGeneration = try await bedrock.generateImage(
    "A serene landscape with mountains at sunset",
    with: model
)
```

Optionally add inference parameters.

```swift
let imageGeneration = try await bedrock.generateImage(
    "A serene landscape with mountains at sunset",
    with: model,
    negativePrompt: "dark, stormy, people",
    nrOfImages: 3,
    cfgScale: 7.0,
    seed: 42,
    quality: .standard,
    resolution: ImageResolution(width: 100, height: 100)
)
```

Note that the minimum, maximum and default values for each parameter are model specific and defined when the BedrockModel is created. Some parameters might not be supported by certain models.

## Generating image variations using the InvokeModel API
Choose a BedrockModel that supports image variations - you can verify this using the `hasImageVariationModality` and the `hasImageVariationModality` function. The `generateImageVariation` function allows you to create variations of an existing image with these parameters:

- `images`: The base64-encoded source images used to create variations from
- `negativePrompt`: Text describing what to avoid in the generated image
- `similarity`: Controls how similar the variations will be to the source images
- `nrOfImages`: Number of variations to generate
- `cfgScale`: Classifier free guidance scale to control how closely variations follow the original image
- `seed`: Seed for reproducible variation generation
- `quality`: Parameter to control the quality of generated variations
- `resolution`: Desired resolution for the output variations

This function returns an `ImageGenerationOutput` object containing an array of generated image variations in base64 format. Each variation will maintain key characteristics of the source images while introducing creative differences.

```swift
let model: BedrockModel = .nova_canvas

guard model.hasImageVariationModality(),
      model.hasImageVariationModality() else {
    throw MyError.incorrectModality("\(model.name) does not support image variation generation")
}

let imageVariations = try await bedrock.generateImageVariation(
    images: [base64EncodedImage],
    prompt: "A dog drinking out of this teacup",
    with: model
)
```

Optionally add inference parameters.

```swift
let imageVariations = try await bedrock.generateImageVariation(
    images: [base64EncodedImage],
    prompt: "A dog drinking out of this teacup",
    with: model,
    negativePrompt: "Cats, worms, rain",
    similarity: 0.8,
    nrOfVariations: 4,
    cfgScale: 7.0,
    seed: 42,
    quality: .standard,
    resolution: ImageResolution(width: 100, height: 100)
)
```

Note that the minimum, maximum and default values for each parameter are model specific and defined when the BedrockModel is created. Some parameters might not be supported by certain models.

## Generating text using the InvokeModel API

Choose a BedrockModel that supports text generation, you can verify this using the `hasTextModality` function. when calling the `completeText` function you can provide some inference parameters: 

- `maxTokens`: The maximum amount of tokens that the model is allowed to return
- `temperature`: Controls the randomness of the model's output
- `topP`: Nucleus sampling, this parameter controls the cumulative probability threshold for token selection
- `topK`: Limits the number of tokens the model considers for each step of text generation to the K most likely ones
- `stopSequences`: An array of strings that will cause the model to stop generating further text when encountered

The function returns a `TextCompletion` object containg the generated text.

```swift
let model: BedrockModel = .nova_micro

guard model.hasTextModality() else {
    throw MyError.incorrectModality("\(model.name) does not support text generation")
}

let textCompletion = try await bedrock.completeText(
    "Write a story about a space adventure",
    with: model
)

print(textCompletion.completion)
```

Optionally add inference parameters.

```swift
let textCompletion = try await bedrock.completeText(
    "Write a story about a space adventure",
    with: model,
    maxTokens: 1000,
    temperature: 0.7,
    topP: 0.9,
    topK: 250,
    stopSequences: ["THE END"]
)
```

Note that the minimum, maximum and default values for each parameter are model specific and defined when the BedrockModel is created. Some parameters might not be supported by certain models.

## How to add a BedrockModel

### Converse

To add a new model that only needs the ConverseModality, simply use the `StandardConverse` and add the correct [inferece parameters](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters.html) and [supported converse features](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-supported-models-features.html).

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

If the model also implements other modalities you might need to create you own `Modality` and make sure it conforms to `ConverseModality` by implementing the `getConverseParameters` and `getConverseFeatures` functions. Note that the `ConverseParameters` can be extracted from `TextGenerationParameters` by using the public initializer.

```swift
struct ModelFamilyModality: TextModality, ConverseModality {
    func getName() -> String { "Model Family Text and Converse Modality" }

    let parameters: TextGenerationParameters
    let converseFeatures: [ConverseFeature]
    let converseParameters: ConverseParameters

    init(parameters: TextGenerationParameters, features: [ConverseFeature] = [.textGeneration]) {
        self.parameters = parameters
        self.converseFeatures = features

        // public initializer to extract `ConverseParameters` from `TextGenerationParameters`
        self.converseParameters = ConverseParameters(textGenerationParameters: parameters) 
    }

    // ...
}
```

### Text

If you need to add a model from a model family that is not supported at all byt the library, follow these steps:

#### Step 1: Create family-specific request and response struct

Make sure to create a struct that reflects exactly how the body of the request for an invokeModel call to this family should look. Make sure to add the public initializer with parameters `prompt`, `maxTokens` and `temperature` to comply to the `BedrockBodyCodable` protocol. Take a look at the documentation to apply best practices or specific formatting.

```json
{
    "prompt": "\(prompt)",
    "temperature": 1, 
    "top_p": 0.9,
    "max_tokens": 200,
    "stop": ["END"]
}
```

```swift
public struct LlamaRequestBody: BedrockBodyCodable {
    let prompt: String
    let max_gen_len: Int
    let temperature: Double
    let top_p: Double

    public init(prompt: String, maxTokens: Int = 512, temperature: Double = 0.5) {
        self.prompt =
            "<|begin_of_text|><|start_header_id|>user<|end_header_id|>\(prompt)<|eot_id|><|start_header_id|>assistant<|end_header_id|>"
        self.max_gen_len = maxTokens
        self.temperature = temperature
        self.top_p = 0.9
    }
}
```

Do the same for the response and ensure to add the `getTextCompletion` method to extract the completion from the response body and to comply to the `ContainsTextCompletion` protocol.

```json
{
    "generation": "\n\n<response>",
    "prompt_token_count": int,
    "generation_token_count": int,
    "stop_reason" : string
}
```

```swift
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

#### Step 2: Create the the Modality

For a text generation create a struct conforming to TextModality. Use the request body and response body you created in  [the previous step](#step-1-create-family-specific-request-and-response-struct). Make sure to check for model(family) specific rules or parameters that are not supported here.

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
            throw BedrockServiceError.notSupported("TopK is not supported for Llama text completion")
        }
        guard stopSequences == nil else {
            throw BedrockServiceError.notSupported("stopSequences is not supported for Llama text completion")
        }
        return LlamaRequestBody(
            prompt: prompt,
            maxTokens: maxTokens ?? parameters.maxTokens.defaultValue,
            temperature: temperature ?? parameters.temperature.defaultValue,
            topP: topP ?? parameters.topP.defaultValue
        )
    }

    func getTextResponseBody(from data: Data) throws -> ContainsTextCompletion {
        let decoder = JSONDecoder()
        return try decoder.decode(LlamaResponseBody.self, from: data)
    }
}
```

#### Step 3: Create BedrockModel instance

You can now create instances for any of the models that follow the request and response structure you defined. Make sure to check the allowed and default values for the inference parameters, especially if some parameters are not supported buy the model. Know that these parameters may differ significantly for model from the same family.

```swift
extension BedrockModel {
    public static let llama3_3_70b_instruct: BedrockModel = BedrockModel(
        id: "us.meta.llama3-3-70b-instruct-v1:0",
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

### Image

To add an image generation model from a model family that is not supported at all byt the library, the steps are much alike to the text completion models.

#### Step 1: Create family-specific request and response struct

Make sure to create a struct that reflects exactly how the body of the request for an invokeModel call to this family should look. Take a look at the documentation to apply best practices or specific formatting. 

```swift
public struct AmazonImageRequestBody: BedrockBodyCodable {
    let taskType: TaskType
    private let textToImageParams: TextToImageParams?
    private let imageGenerationConfig: ImageGenerationConfig

    // MARK: - Initialization

    /// Creates a text-to-image generation request body
    /// - Parameters:
    ///   - prompt: The text description of the image to generate
    ///   - nrOfImages: The number of images to generate
    ///   - negativeText: The text description of what to exclude from the generated image
    /// - Returns: A configured AmazonImageRequestBody for text-to-image generation
    public static func textToImage(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) -> Self {
        AmazonImageRequestBody(
            prompt: prompt,
            negativeText: negativeText,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }

    private init(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) {
        self.taskType = .textToImage
        self.textToImageParams = TextToImageParams.textToImage(prompt: prompt, negativeText: negativeText)
        self.imageGenerationConfig = ImageGenerationConfig(
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }
}
```

Do the same for the response and ensure to add the `getGeneratedImage` method to extract the image from the response body and to comply to the `ContainsImageGeneration` protocol.

```swift
public struct AmazonImageResponseBody: ContainsImageGeneration {
    let images: [Data]

    public func getGeneratedImage() -> ImageGenerationOutput {
        ImageGenerationOutput(images: images)
    }
}
```

#### Step 2: Create the the Modality

Determine the exact functionality and make sure to comply to the correct modality protocol. In this case we will use `TextToImageModality`.
Create a struct conforming to `ImageModality` and the specific functionality protocol. Use the request body and response body you created in [the previous step](#step-1-create-family-specific-request-and-response-struct). Make sure to check for model(family) specific rules or parameters that are not supported here.

```swift
struct AmazonImage: ImageModality, TextToImageModality {
    func getName() -> String { "Amazon Image Generation" }

    let parameters: ImageGenerationParameters
    let resolutionValidator: any ImageResolutionValidator
    let textToImageParameters: TextToImageParameters

    init(
        parameters: ImageGenerationParameters,
        resolutionValidator: any ImageResolutionValidator,
        textToImageParameters: TextToImageParameters
    ) {
        self.parameters = parameters
        self.textToImageParameters = textToImageParameters
        self.conditionedTextToImageParameters = conditionedTextToImageParameters
        self.imageVariationParameters = imageVariationParameters
        self.resolutionValidator = resolutionValidator
    }

    func getParameters() -> ImageGenerationParameters { parameters }
    func getTextToImageParameters() -> TextToImageParameters { textToImageParameters }

    func validateResolution(_ resolution: ImageResolution) throws {
        try resolutionValidator.validateResolution(resolution)
    }

    func getImageResponseBody(from data: Data) throws -> ContainsImageGeneration {
        let decoder = JSONDecoder()
        return try decoder.decode(AmazonImageResponseBody.self, from: data)
    }

    func getTextToImageRequestBody(
        prompt: String,
        negativeText: String?,
        nrOfImages: Int?,
        cfgScale: Double?,
        seed: Int?,
        quality: ImageQuality?,
        resolution: ImageResolution?
    ) throws -> BedrockBodyCodable {
        AmazonImageRequestBody.textToImage(
            prompt: prompt,
            negativeText: negativeText,
            nrOfImages: nrOfImages,
            cfgScale: cfgScale,
            seed: seed,
            quality: quality,
            resolution: resolution
        )
    }
}
```

#### Step 3: Create BedrockModel instance

You can now create instances for any of the models that follow the request and response structure you defined. Make sure to check the allowed and default values for the inference parameters, especially if some parameters are not supported buy the model. Know that these parameters may differ significantly for model from the same family.

```swift
extension BedrockModel {
    public static let nova_canvas: BedrockModel = BedrockModel(
        id: "amazon.nova-canvas-v1:0",
        name: "Nova Canvas",
        modality: AmazonImage(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 5, defaultValue: 1),
                cfgScale: Parameter(.cfgScale, minValue: 1.1, maxValue: 10, defaultValue: 6.5),
                seed: Parameter(.seed, minValue: 0, maxValue: 858_993_459, defaultValue: 12)
            ),
            resolutionValidator: NovaImageResolutionValidator(),
            textToImageParameters: TextToImageParameters(maxPromptSize: 1024, maxNegativePromptSize: 1024),
        )
    )
}
```