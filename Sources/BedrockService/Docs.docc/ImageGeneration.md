# Image Generation

Create and modify images with foundation models

## Overview

BedrockService supports image generation and variation capabilities, allowing you to create images from text descriptions and generate variations of existing images.

## Text-to-Image Generation

Generate images from text descriptions:

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

// Access generated images
for (index, image) in imageGeneration.images.enumerated() {
    print("Generated image \(index + 1): \(image.prefix(50))...")
}
```

## Generation Parameters

Control image generation with various parameters:

```swift
let imageGeneration = try await bedrock.generateImage(
    "A futuristic city skyline at night",
    with: model,
    negativePrompt: "dark, gloomy, abandoned",
    nrOfImages: 3,
    cfgScale: 7.0,
    seed: 42,
    quality: .standard,
    resolution: ImageResolution(width: 1024, height: 1024)
)
```

### Available Parameters

- **negativePrompt**: Describe what to avoid in the image
- **nrOfImages**: Number of images to generate (1-4 typically)
- **cfgScale**: How closely to follow the prompt (1.0-20.0)
- **seed**: For reproducible results
- **quality**: Image quality setting (`.standard`, `.premium`)
- **resolution**: Output image dimensions

## Image Variations

Create variations of existing images:

```swift
let model: BedrockModel = .nova_canvas

guard model.hasImageModality(),
      model.hasImageVariationModality() else {
    throw MyError.incorrectModality("\(model.name) does not support image variations")
}

let imageVariations = try await bedrock.generateImageVariation(
    images: [base64EncodedImage],
    prompt: "A dog drinking from this teacup",
    with: model
)
```

## Variation Parameters

Fine-tune image variations:

```swift
let imageVariations = try await bedrock.generateImageVariation(
    images: [base64EncodedImage],
    prompt: "Transform this into a watercolor painting",
    with: model,
    negativePrompt: "photorealistic, sharp edges",
    similarity: 0.8,
    nrOfVariations: 4,
    cfgScale: 7.0,
    seed: 123,
    quality: .premium,
    resolution: ImageResolution(width: 512, height: 512)
)
```

### Variation-Specific Parameters

- **similarity**: How similar variations should be to source (0.0-1.0)
- **nrOfVariations**: Number of variations to create

## Working with Image Data

Handle base64-encoded image data:

```swift
// Convert image file to base64
func loadImageAsBase64(from path: String) -> String? {
    guard let imageData = FileManager.default.contents(atPath: path) else {
        return nil
    }
    return imageData.base64EncodedString()
}

// Save generated image
func saveBase64Image(_ base64String: String, to path: String) {
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Invalid base64 data")
        return
    }
    
    do {
        try imageData.write(to: URL(fileURLWithPath: path))
        print("Image saved to \(path)")
    } catch {
        print("Failed to save image: \(error)")
    }
}

// Usage
if let sourceImage = loadImageAsBase64(from: "input.jpg") {
    let variations = try await bedrock.generateImageVariation(
        images: [sourceImage],
        prompt: "Make this image look like a vintage photograph",
        with: model
    )
    
    for (index, image) in variations.images.enumerated() {
        saveBase64Image(image, to: "variation_\(index).jpg")
    }
}
```

## Model-Specific Capabilities

Different models support different features:

```swift
// Check model capabilities
let model: BedrockModel = .nova_canvas

if model.hasTextToImageModality() {
    print("Supports text-to-image generation")
}

if model.hasImageVariationModality() {
    print("Supports image variations")
}

// Get model-specific parameter limits
if let imageModality = model.modality as? ImageModality {
    let params = imageModality.getImageGenerationParameters()
    print("Max images: \(params.nrOfImages.maxValue ?? "unlimited")")
    print("CFG scale range: \(params.cfgScale.minValue)-\(params.cfgScale.maxValue ?? 20)")
}
```

## Error Handling

Handle common image generation errors:

```swift
do {
    let images = try await bedrock.generateImage(
        "A beautiful sunset over the ocean",
        with: model,
        nrOfImages: 5 // Might exceed model limit
    )
} catch BedrockServiceError.parameterOutOfRange(let parameter, let value, let range) {
    print("Parameter \(parameter) value \(value) is outside allowed range: \(range)")
} catch BedrockServiceError.notSupported(let feature) {
    print("Feature not supported: \(feature)")
} catch {
    print("Image generation failed: \(error)")
}
```

## See Also

- <doc:Vision>
- <doc:Converse>