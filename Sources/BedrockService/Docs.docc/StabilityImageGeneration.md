# Stability AI Image Generation

Generate images with Stability AI models on Amazon Bedrock.

## Overview

Stability AI provides the only generic text-to-image models currently active on Amazon Bedrock. They are available in **us-west-2** only.

| Constant | Bedrock model ID | Notes |
| -------- | ---------------- | ----- |
| ``BedrockModel/stable_image_core`` | `stability.stable-image-core-v1:1` | Text-to-image only. |
| ``BedrockModel/stable_image_ultra`` | `stability.stable-image-ultra-v1:1` | Text-to-image only. |
| ``BedrockModel/sd3_5_large`` | `stability.sd3-5-large-v1:0` | Text-to-image; supports `negativePrompt`. Image-to-image is registered as a follow-up. |

## Quick start

```swift
import BedrockService

let bedrock = try await BedrockService(region: .uswest2)

let output = try await bedrock.generateImage(
    "A serene landscape with mountains at sunset",
    with: .stable_image_core,
    seed: 42,
    resolution: ImageResolution(width: 1920, height: 1080)
)

if let png = output.images.first {
    try png.write(to: URL(fileURLWithPath: "out.png"))
}
```

## Parameter mapping

The shared `generateImage` API surface is unchanged for Stability models, but several parameters behave differently than for Nova Canvas:

- **`resolution`** is mapped to the closest supported `aspect_ratio` string. Supported ratios are `16:9`, `1:1`, `21:9`, `2:3`, `3:2`, `4:5`, `5:4`, `9:16`, `9:21`. Resolutions more extreme than `21:9` (or `9:21`) are rejected with `BedrockLibraryError.invalidParameter`.
- **`nrOfImages`** must be `nil` or `1` — Stability models always return exactly one image per call. Any other value throws `BedrockLibraryError.notSupported`.
- **`cfgScale`** is not supported by Stability models. Any non-`nil` value throws `BedrockLibraryError.notSupported`.
- **`quality`** is not supported by Stability models. Any non-`nil` value throws `BedrockLibraryError.notSupported`.
- **`negativePrompt`** is supported only by ``BedrockModel/sd3_5_large`` (max 10 000 characters). Passing a non-`nil` value to ``BedrockModel/stable_image_core`` or ``BedrockModel/stable_image_ultra`` throws `BedrockLibraryError.notSupported`.
- **`seed`** must be in the range `0...4_294_967_295`.

The output format is currently fixed to PNG.

## Error handling

```swift
do {
    let output = try await bedrock.generateImage(
        "A futuristic city skyline at night",
        with: .stable_image_core,
        nrOfImages: 3
    )
} catch BedrockLibraryError.notSupported(let message) {
    print("Stability rejected the request: \(message)")
} catch BedrockLibraryError.invalidParameter(let parameter, let message) {
    print("Invalid parameter \(parameter): \(message)")
} catch {
    print("Image generation failed: \(error)")
}
```

## See Also

- <doc:ImageGeneration>
- <doc:Vision>
