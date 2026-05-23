# Tasks: Stability AI Text-to-Image Models

## Task 1: Scaffold the Stability model directory
- [ ] Create `Sources/BedrockService/Models/Stability/`
- [ ] Add Apache-2.0 license headers matching existing files

## Task 2: Aspect ratio mapping
- [ ] Add `StabilityAspectRatio` enum (`StabilityAspectRatio.swift`) with all 9 supported ratios
- [ ] Implement `static func nearest(to: ImageResolution) -> StabilityAspectRatio` (minimize `|w/h - ratio|`)
- [ ] Add unit tests covering: square inputs → `1:1`, common landscape/portrait inputs → `16:9` / `9:16`, edge cases at the midpoint between two ratios

## Task 3: Resolution validator
- [ ] Add `StabilityImageResolutionValidator` conforming to `ImageResolutionValidator`
- [ ] Validate width/height > 0
- [ ] Reject ratios outside the supported set with `BedrockLibraryError.invalidParameter(.resolution, ...)`

## Task 4: Request body
- [ ] Add `StabilityImageRequestBody` conforming to `BedrockBodyCodable`
- [ ] Provide a `static func textToImage(...)` factory
- [ ] Implement custom `encode(to:)` so `negative_prompt`, `aspect_ratio`, `seed`, and `mode` are omitted when nil
- [ ] Hard-code `output_format = "png"` for now (REQ-8)

## Task 5: Response body
- [ ] Add `StabilityImageResponseBody` conforming to `ContainsImageGeneration`
- [ ] Decode `images: [String]`, `seeds: [Int]?`, `finish_reasons: [String?]?`
- [ ] In `getGeneratedImage()`, base64-decode each image to `Data`

## Task 6: Modality conformance
- [ ] Add `StabilityImage` struct conforming to `ImageModality` and `TextToImageModality`
- [ ] `getName()` returns `"Stability Image Generation"`
- [ ] In `getTextToImageRequestBody(...)`, reject `nrOfImages != 1`, non-nil `cfgScale`, non-nil `quality`, and non-nil `negativeText` for Core/Ultra (REQ-3, REQ-4, REQ-5)
- [ ] Map `resolution` to `StabilityAspectRatio.nearest(to:)` before constructing the body

## Task 7: Register `BedrockModel` constants
- [ ] Add `StabilityBedrockModels.swift` with `stable_image_core`, `stable_image_ultra`, `sd3_5_large`
- [ ] Use seed range `0...4_294_967_295` (REQ-7)
- [ ] Set `maxPromptSize = 10_000` for all; `maxNegativePromptSize = 10_000` only for `sd3_5_large` (REQ-3)
- [ ] Resolve the `cfgScale`/`nrOfImages` placeholder approach (see "Open question" in design.md) — start with placeholder zero ranges

## Task 8: Mock client
- [ ] Add a `case "Stability Image Generation":` branch in `Tests/Mock/MockBedrockRuntimeClient.invokeModel(...)`
- [ ] Return a Stability-shaped JSON: `{ "seeds": [0], "finish_reasons": [null], "images": ["<base64>"] }`
- [ ] Use the same mock 1×1 PNG base64 already used by `getImageGeneration(...)`

## Task 9: Unit tests — end-to-end (REQ-11, REQ-14)
- [ ] Create `Tests/InvokeModel/StabilityImageGenerationTests.swift`
- [ ] Add a `StabilityTestConstants` enum (new file) mirroring `NovaTestConstants` patterns, with a `imageGenerationModels` array containing all three Stability models
- [ ] Parametric test: valid prompt → 1 image, iterating over all three models
- [ ] Empty / oversized prompt → throws, iterating over all three models
- [ ] `nrOfImages` boundary test: `nil` and `1` succeed, every other value throws
- [ ] Non-nil `cfgScale` → throws (parametric over a small range)
- [ ] Non-nil `quality` → throws
- [ ] `negativePrompt` on Core/Ultra → throws; on `sd3_5_large` → succeeds
- [ ] Seed boundaries: `0` and `4_294_967_295` succeed; `-1` and `4_294_967_296` throw

## Task 10: Unit tests — request body & response (REQ-14)
- [ ] Create `Tests/Stability/StabilityRequestBodyTests.swift`
- [ ] Encode the body, decode back into `[String: Any]`, and assert key presence/absence per model variant:
  - Core/Ultra: no `negative_prompt`, no `mode` keys
  - `sd3_5_large` with negativeText: `negative_prompt` present, `mode` present
  - `aspect_ratio` and `seed` omitted when nil
- [ ] Verify `output_format` is always `"png"` in the encoded JSON
- [ ] Create `Tests/Stability/StabilityResponseBodyTests.swift` covering `getGeneratedImage()` with valid base64 (round-trip equality) and malformed base64 (decoded count == 0)

## Task 11: Unit tests — aspect ratio & resolution (REQ-14)
- [ ] Create `Tests/Stability/StabilityAspectRatioTests.swift`
- [ ] Table-driven `nearest(to:)` test: at least one input per supported ratio, plus midpoint cases between adjacent ratios
- [ ] Resolution mapping smoke tests: `(1024,1024) → 1:1`, `(1920,1080) → 16:9`, `(1080,1920) → 9:16`, `(2100,900) → 21:9`
- [ ] `StabilityImageResolutionValidator` rejection cases: `width=0`, `height=0`, ratio outside the supported set

## Task 12: Mock client wiring
- [ ] Add a `case "Stability Image Generation":` branch in `Tests/Mock/MockBedrockRuntimeClient.invokeModel(...)`
- [ ] Return `{ "seeds": [0], "finish_reasons": [null], "images": ["<base64>"] }` using the same 1×1 PNG mock as the Nova path
  > (This was Task 8 in the previous numbering — kept here for sequencing.)

## Task 13: DocC article (REQ-16)
- [ ] Add `Sources/BedrockService/Docs.docc/StabilityImageGeneration.md` covering: region availability, model identifiers, parameter mapping (resolution → aspect ratio, single-image contract, rejected params), a working `generateImage` snippet using `stable_image_core`
- [ ] Add a `<doc:StabilityImageGeneration>` entry to the **See Also** section of `ImageGeneration.md`
- [ ] Build the docs locally (e.g. `swift package generate-documentation --target BedrockService`) and confirm the new article appears and links resolve

## Task 14: Cheatsheet
- [ ] Add a "Stability" section to `parameter_cheatsheet.md` with one table per model

## Task 15: Example project (REQ-15)
- [ ] Create `Examples/stability-image/Package.swift` mirroring `Examples/embeddings/Package.swift` (executable target, local path dep on `swift-bedrock-library`, `swift-log` dep)
- [ ] Create `Examples/stability-image/Sources/StabilityImage/StabilityImage.swift` calling `bedrock.generateImage(...)` with `.stable_image_core` and writing the PNG to disk
- [ ] Verify `swift build` succeeds inside `Examples/stability-image/` (no AWS credentials needed for build)

## Task 16: CI integration (REQ-15)
- [ ] In `.github/workflows/pull_request.yml`, append `'stability-image'` to the `examples` JSON array in the `integration-tests` job
- [ ] Push a draft PR (or run the workflow via `workflow_dispatch`) and confirm the new example gets built

## Task 17: Build, format, test
- [ ] `swift build` clean
- [ ] `swift test` clean (existing tests must not regress)
- [ ] `swift format` per repository steering rules
- [ ] If a coverage tool is available locally, run `swift test --enable-code-coverage` and confirm the new files exceed a reasonable threshold (target ≥ 90 % of lines / branches in the new Stability sources)

## Task 18: Manual verification (optional, requires AWS credentials)
- [ ] Run the new example in `us-west-2` and verify a PNG is decoded into `Data`
- [ ] Confirm error paths surface readable messages (`negativePrompt` on Core, `nrOfImages: 3`, `cfgScale: 5`)

## Follow-ups (not in this change)
- [ ] Image-to-image for `sd3-5-large-v1:0` (mode = `image-to-image`, requires a reference image and `strength`) — likely needs a new modality protocol since the semantics differ from `ImageVariationModality`
- [ ] Public API for selecting `output_format` (jpeg vs png)
- [ ] The Stability editing tools (upscale, inpaint, outpaint, style transfer) in `us-east-1`/`us-east-2`
