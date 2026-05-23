# Design: Stability AI Text-to-Image Models

## Architecture

The library already has clean extension points for new image-generation providers:

- A model declares its capabilities by conforming its `modality` to one or more protocols in `Sources/BedrockService/BedrockRuntimeClient/Modalities/ImageModality.swift` (`ImageModality`, `TextToImageModality`, `ConditionedTextToImageModality`, `ImageVariationModality`).
- `BedrockService.generateImage(...)` (in `BedrockService+InvokeModelImage.swift`) is provider-agnostic. It validates parameters via `validateTextToImageParams`, builds the body through `model.getTextToImageModality().getTextToImageRequestBody(...)`, and decodes the response through `model.getImageModality().getImageResponseBody(...)`.
- The Amazon Nova Canvas implementation lives in `Sources/BedrockService/Models/Amazon/` (`AmazonImage.swift`, `AmazonImageRequestBody.swift`, `AmazonImageResponseBody.swift`, `Nova/NovaBedrockModels.swift`, `Nova/NovaImageResolutionValidator.swift`).

The Stability implementation mirrors the Nova layout in a new `Sources/BedrockService/Models/Stability/` directory. No changes to public-API method signatures are required — Stability slots into the protocol-based dispatch.

## File layout

```
Sources/BedrockService/Models/Stability/
├── StabilityImage.swift                  // modality conformance
├── StabilityImageRequestBody.swift       // BedrockBodyCodable
├── StabilityImageResponseBody.swift      // ContainsImageGeneration
├── StabilityImageResolutionValidator.swift
├── StabilityAspectRatio.swift            // enum + ImageResolution mapping
└── StabilityBedrockModels.swift          // BedrockModel constants
```

## Type design

### 1. `StabilityAspectRatio`

```swift
public enum StabilityAspectRatio: String, Codable, Sendable, CaseIterable {
    case r16x9 = "16:9"
    case r1x1  = "1:1"
    case r21x9 = "21:9"
    case r2x3  = "2:3"
    case r3x2  = "3:2"
    case r4x5  = "4:5"
    case r5x4  = "5:4"
    case r9x16 = "9:16"
    case r9x21 = "9:21"

    /// Returns the nearest supported aspect ratio for an `ImageResolution`.
    static func nearest(to resolution: ImageResolution) -> StabilityAspectRatio { /* min |w/h - ratio| */ }
}
```

### 2. `StabilityImageResolutionValidator`

Implements `ImageResolutionValidator`. Stability does not enforce pixel dimensions on input the way Nova does — instead it picks dimensions from the aspect ratio. Validation:

- Width and height > 0.
- The computed nearest aspect ratio must exist in `StabilityAspectRatio`.
- Reject obviously degenerate ratios (e.g. > 21:1) with `BedrockLibraryError.invalidParameter(.resolution, ...)`.

Resolution → aspect ratio mapping happens at request-body construction time (request body holds an `aspect_ratio` string, not width/height).

### 3. `StabilityImageRequestBody`

```swift
public struct StabilityImageRequestBody: BedrockBodyCodable {
    let prompt: String
    let negativePrompt: String?       // omitted for core/ultra
    let aspectRatio: String?          // "1:1" etc.
    let seed: Int?
    let outputFormat: String          // "png" (hard-coded for now)
    let mode: String?                 // sd3-5-large only

    enum CodingKeys: String, CodingKey {
        case prompt
        case negativePrompt   = "negative_prompt"
        case aspectRatio      = "aspect_ratio"
        case seed
        case outputFormat     = "output_format"
        case mode
    }

    static func textToImage(
        prompt: String,
        negativePrompt: String?,
        aspectRatio: StabilityAspectRatio?,
        seed: Int?,
        supportsNegativePrompt: Bool,
        supportsMode: Bool
    ) -> Self { /* ... */ }
}
```

`encode(to:)` is implemented manually so unset optionals (notably `negative_prompt` for Core/Ultra and `mode` for non-SD3.5) are omitted from the JSON entirely — Bedrock rejects unknown fields on these models.

### 4. `StabilityImageResponseBody`

```swift
public struct StabilityImageResponseBody: ContainsImageGeneration {
    let images: [String]               // base64-encoded
    let seeds: [Int]?
    let finishReasons: [String?]?

    enum CodingKeys: String, CodingKey {
        case images
        case seeds
        case finishReasons = "finish_reasons"
    }

    public func getGeneratedImage() -> ImageGenerationOutput {
        let datas: [Data] = images.compactMap { Data(base64Encoded: $0) }
        return ImageGenerationOutput(images: datas)
    }
}
```

### 5. `StabilityImage` (modality)

```swift
struct StabilityImage: ImageModality, TextToImageModality {
    let parameters: ImageGenerationParameters
    let textToImageParameters: TextToImageParameters
    let resolutionValidator: any ImageResolutionValidator
    let supportsNegativePrompt: Bool   // false for core/ultra, true for sd3-5-large
    let supportsMode: Bool             // true for sd3-5-large only

    func getName() -> String { "Stability Image Generation" }

    func getParameters() -> ImageGenerationParameters { parameters }
    func getTextToImageParameters() -> TextToImageParameters { textToImageParameters }

    func validateResolution(_ resolution: ImageResolution) throws {
        try resolutionValidator.validateResolution(resolution)
    }

    func getImageResponseBody(from data: Data) throws -> ContainsImageGeneration {
        try JSONDecoder().decode(StabilityImageResponseBody.self, from: data)
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
        // Reject unsupported parameters loudly:
        if let nrOfImages, nrOfImages != 1 {
            throw BedrockLibraryError.notSupported(
                "Stability models generate exactly 1 image per request; nrOfImages=\(nrOfImages) is not supported"
            )
        }
        if cfgScale != nil {
            throw BedrockLibraryError.notSupported("cfgScale is not supported by Stability models")
        }
        if quality != nil {
            throw BedrockLibraryError.notSupported("quality is not supported by Stability models")
        }
        if !supportsNegativePrompt, negativeText != nil {
            throw BedrockLibraryError.notSupported(
                "negativePrompt is only supported by stability.sd3-5-large-v1:0"
            )
        }

        let aspect = resolution.map(StabilityAspectRatio.nearest(to:))
        return StabilityImageRequestBody.textToImage(
            prompt: prompt,
            negativePrompt: negativeText,
            aspectRatio: aspect,
            seed: seed,
            supportsNegativePrompt: supportsNegativePrompt,
            supportsMode: supportsMode
        )
    }
}
```

### 6. `BedrockModel` constants — `StabilityBedrockModels.swift`

```swift
extension BedrockModel {
    public static let stable_image_core: BedrockModel = BedrockModel(
        id: "stability.stable-image-core-v1:1",
        name: "Stable Image Core",
        modality: StabilityImage(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 1, defaultValue: 1),
                cfgScale:   Parameter(.cfgScale,   minValue: 0, maxValue: 0, defaultValue: 0),
                seed:       Parameter(.seed,       minValue: 0, maxValue: 4_294_967_295, defaultValue: 0)
            ),
            textToImageParameters: TextToImageParameters(maxPromptSize: 10_000, maxNegativePromptSize: 0),
            resolutionValidator: StabilityImageResolutionValidator(),
            supportsNegativePrompt: false,
            supportsMode: false
        )
    )

    public static let stable_image_ultra: BedrockModel = BedrockModel(
        id: "stability.stable-image-ultra-v1:1",
        name: "Stable Image Ultra",
        modality: StabilityImage(/* same shape as Core */)
    )

    public static let sd3_5_large: BedrockModel = BedrockModel(
        id: "stability.sd3-5-large-v1:0",
        name: "Stable Diffusion 3.5 Large",
        modality: StabilityImage(
            parameters: ImageGenerationParameters(
                nrOfImages: Parameter(.nrOfImages, minValue: 1, maxValue: 1, defaultValue: 1),
                cfgScale:   Parameter(.cfgScale,   minValue: 0, maxValue: 0, defaultValue: 0),
                seed:       Parameter(.seed,       minValue: 0, maxValue: 4_294_967_295, defaultValue: 0)
            ),
            textToImageParameters: TextToImageParameters(maxPromptSize: 10_000, maxNegativePromptSize: 10_000),
            resolutionValidator: StabilityImageResolutionValidator(),
            supportsNegativePrompt: true,
            supportsMode: true
        )
    )
}
```

> Note: `cfgScale` is declared with `minValue == maxValue == 0` only as a placeholder so the `ImageGenerationParameters` initializer has a value. The modality's own `getTextToImageRequestBody` rejects any non-nil `cfgScale` *before* the parameter range is checked, so users always get a clear "not supported" message rather than a confusing range error. If preferred, we can add an `Optional<Parameter<Double>>` overload to `ImageGenerationParameters` instead — see the open question below.

## Validation flow

`BedrockService+ImageParameterValidation.swift` already routes through `model.getImageModality().getParameters()` and `model.getTextToImageModality().getTextToImageParameters()`. No changes needed there. Stability-specific rejections live in `StabilityImage.getTextToImageRequestBody(...)` so they fire after generic validation passes.

## Mock & tests

- Add a `case "Stability Image Generation":` branch to `MockBedrockRuntimeClient.invokeModel(...)` that returns a Stability-shaped JSON body with one image and a seed.
- Add a `Tests/InvokeModel/StabilityImageGenerationTests.swift` mirroring `ImageGenerationTests.swift`. Reuse the parametric pattern with a `StabilityTestConstants` enum (or extend `NovaTestConstants` — favor a new file to keep the Nova file tidy).
- Add an `imageGenerationModels` array containing the three Stability models for iteration tests; keep the Nova/Titan list separate to avoid cross-pollinating parameter expectations (e.g. `nrOfImages > 1` is valid for Nova but invalid for Stability).

## Test coverage (REQ-14)

The new code must be covered by Swift Testing tests in three new files:

- `Tests/InvokeModel/StabilityImageGenerationTests.swift` — end-to-end behavior through `bedrock.generateImage(...)` for all three models, parametrized via a `StabilityTestConstants` enum mirroring `NovaTestConstants`.
- `Tests/Stability/StabilityRequestBodyTests.swift` — encodes a `StabilityImageRequestBody`, decodes the JSON back into a dictionary, and asserts which keys are present/absent for each model variant. Covers `negative_prompt` omitted on Core/Ultra, `mode` omitted unless `supportsMode`, and `aspect_ratio` / `seed` omitted when nil.
- `Tests/Stability/StabilityAspectRatioTests.swift` — table-driven `nearest(to:)` test plus rejection cases on `StabilityImageResolutionValidator`.

The unit tests must also exercise base64 decoding in `StabilityImageResponseBody.getGeneratedImage()` (one valid case, one malformed case). Aim for "every public symbol and every non-trivial branch reached" — measurable by `swift test --enable-code-coverage` if coverage is later wired in. Document any deliberately uncovered path inline with a `// swiftformat:disable` or `// not exercised: <reason>` comment.

## Example project (REQ-15)

Create a new standalone example package mirroring `Examples/embeddings/`:

```
Examples/stability-image/
├── Package.swift
└── Sources/
    └── StabilityImage/
        └── StabilityImage.swift
```

`Package.swift` skeleton (matches the structure of existing examples):

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StabilityImage",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18)],
    products: [
        .executable(name: "StabilityImage", targets: ["StabilityImage"])
    ],
    dependencies: [
        .package(name: "swift-bedrock-library", path: "../.."),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "StabilityImage",
            dependencies: [
                .product(name: "BedrockService", package: "swift-bedrock-library"),
                .product(name: "Logging", package: "swift-log"),
            ]
        )
    ]
)
```

`StabilityImage.swift` calls `BedrockService.generateImage(...)` against `BedrockModel.stable_image_core` in `us-west-2` and writes the decoded PNG bytes to a file in the working directory.

### CI integration

Append `'stability-image'` to the JSON array in the `integration-tests` job of `.github/workflows/pull_request.yml`:

```yaml
examples: "[ 'api-key', 'converse', 'converse-stream', 'embeddings', 'openai', 'retrieve', 'text_chat', 'stability-image' ]"
```

The integration-tests workflow only runs `swift build` against the example, so this does not require AWS credentials.

## DocC documentation (REQ-16)

Add `Sources/BedrockService/Docs.docc/StabilityImageGeneration.md` as a standalone article (preferred over inlining into `ImageGeneration.md` because the differences are substantial enough — different regions, different parameters, different model semantics). Structure:

```
# Stability AI Image Generation
@Metadata { @PageImage(purpose: card, source: "stability-card", alt: "...") }   // optional, only if a card asset already exists

## Overview
- Region availability: us-west-2 only as of 2026-05.
- Models: stable_image_core, stable_image_ultra, sd3_5_large (text-to-image only in this release).

## Model identifiers
| Constant | Bedrock ID | Notes |
| ...      | ...        | ...   |

## Quick start
\`\`\`swift
let bedrock = try await BedrockService(region: .uswest2)
let output = try await bedrock.generateImage(
    "A serene landscape with mountains at sunset",
    with: .stable_image_core,
    seed: 42,
    resolution: ImageResolution(width: 1920, height: 1080)
)
let png = output.images.first!
try png.write(to: URL(fileURLWithPath: "out.png"))
\`\`\`

## Parameter mapping
- `resolution` → nearest supported `aspect_ratio` (16:9, 1:1, 21:9, 2:3, 3:2, 4:5, 5:4, 9:16, 9:21).
- `nrOfImages` must be `nil` or `1` — Stability returns exactly one image per call.
- `cfgScale` and `quality` are not supported and will throw `BedrockLibraryError.notSupported`.
- `negativePrompt` is supported only by `sd3_5_large`.

## See Also
- <doc:ImageGeneration>
```

Cross-link from `ImageGeneration.md`: add a `<doc:StabilityImageGeneration>` entry to its **See Also** section so navigation works in both directions.

## Documentation

- `parameter_cheatsheet.md`: new "Stability" subsection with one table per model.

## Open question

`ImageGenerationParameters` currently requires non-optional `cfgScale` and `nrOfImages` parameters. Two options:

1. **Use placeholder zero ranges** (current sketch above) and rely on the modality to reject unsupported params. Pro: zero churn to shared types. Con: the placeholders look odd in the model definitions.
2. **Make the fields optional** in `ImageGenerationParameters`. Pro: cleaner Stability registration. Con: ripples into `BedrockService+ImageParameterValidation.swift` and `Nova`/`Titan` registrations — wider blast radius.

Recommendation: start with option 1 to keep the change focused. If reviewers prefer cleaner semantics, switch to option 2 in a follow-up.

## Compatibility

- All three models are exclusively in `us-west-2`. Calling them from another region will fail at the SDK layer with the standard "model not found" error; the library does not need region gating.
- The cross-region inference prefix logic in `BedrockModel.getModelIdWithCrossRegionInferencePrefix(region:)` is opt-in per model and is not enabled for these constants.
