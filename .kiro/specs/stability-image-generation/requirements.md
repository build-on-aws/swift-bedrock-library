# Requirements: Add Stability AI Text-to-Image Models

## Overview

Add support for Stability AI text-to-image models on Amazon Bedrock to the `BedrockService` library. These are currently the only generic text-to-image models still active on Bedrock and the only practical replacement for Nova Canvas in regions where Canvas has been retired.

## Background

- Stability AI is the sole vendor with active generic text-to-image models on Bedrock.
- Nova Canvas remains only as a legacy model in `eu-west-1`. Newer regions (notably `us-west-2`) host Stability instead. There is no Amazon first-party replacement yet.
- Supported model IDs (as of 2026-05-23):
  - `stability.stable-image-core-v1:1` — text-to-image only (input: TEXT)
  - `stability.stable-image-ultra-v1:1` — text-to-image only (input: TEXT)
  - `stability.sd3-5-large-v1:0` — Stable Diffusion 3.5 Large (input: TEXT + IMAGE)
- All three are available in `us-west-2` only. `us-east-1` / `us-east-2` only host the specialized Stability editing tools (upscale, inpaint, etc.) which are out of scope here.
- Stability InvokeModel API uses a different request/response schema from Nova Canvas (see "Schema differences" below).

## Schema differences vs Nova Canvas

Stability text-to-image request body fields:

| Field | Type | Notes |
|---|---|---|
| `prompt` | string | required, ≤ 10000 chars |
| `negative_prompt` | string | optional, ≤ 10000 chars (not supported by `stable-image-core` or `stable-image-ultra` — only `sd3-5-large`) |
| `aspect_ratio` | string | optional, one of `16:9`, `1:1`, `21:9`, `2:3`, `3:2`, `4:5`, `5:4`, `9:16`, `9:21`. Default `1:1`. |
| `seed` | int | optional, 0..4_294_967_295, default 0 (random) |
| `output_format` | string | optional, `jpeg` or `png`. Default `png`. |
| `mode` | string | `sd3-5-large` only: `text-to-image` (default) or `image-to-image` |

Stability response body:

```json
{ "seeds": [123], "finish_reasons": [null], "images": ["<base64-png>"] }
```

Single image per call (`numberOfImages` is not a Stability parameter); the `images` array always has exactly one element.

## Requirements

1. **REQ-1**: Register three new `BedrockModel` constants in a new `Stability` model directory:
   - `BedrockModel.stable_image_core`
   - `BedrockModel.stable_image_ultra`
   - `BedrockModel.sd3_5_large`
2. **REQ-2**: Each model must conform to `ImageModality` and `TextToImageModality` so the existing `BedrockService.generateImage(...)` API works without signature changes.
3. **REQ-3**: SD 3.5 Large must additionally accept a non-nil `negativePrompt`. For Core and Ultra, supplying `negativePrompt` must throw `BedrockLibraryError.notSupported` (or equivalent) — the SDK rejects the field for those models.
4. **REQ-4**: `nrOfImages` is not a Stability parameter. Accept only `nil` or `1`; any other value must throw `BedrockLibraryError.invalidParameter`.
5. **REQ-5**: `cfgScale` and `quality` are not Stability parameters. The library must reject any non-nil value for these with a clear "not supported" error to avoid silent ignoring.
6. **REQ-6**: `resolution` (an `ImageResolution`) must be mapped to the nearest supported `aspect_ratio` string by the model's modality. Mapping logic lives in a `StabilityImageResolutionValidator` (see design). Unsupported aspect ratios must throw `BedrockLibraryError.invalidParameter`.
7. **REQ-7**: `seed` validation must use Stability's range: `0..4_294_967_295`.
8. **REQ-8**: Default `output_format` is `png`. Initial scope does not expose `output_format` in the public API; PNG is hard-coded. (Adding it later is a follow-up.)
9. **REQ-9**: Response decoding must convert each base64 string in `images` to `Data` so the existing `ImageGenerationOutput` (`images: [Data]`) is unchanged.
10. **REQ-10**: Image-to-image support for `sd3-5-large-v1:0` is **out of scope** for this change and tracked as a follow-up task. The model is registered as text-to-image only here.
11. **REQ-11**: Add unit tests (Swift Testing) mirroring the patterns in `Tests/InvokeModel/ImageGenerationTests.swift` for all three models, including invalid-parameter cases.
12. **REQ-12**: Extend `Tests/Mock/MockBedrockRuntimeClient.swift` to handle a `"Stability Image Generation"` modality name and return a Stability-shaped JSON response.
13. **REQ-13**: Update `parameter_cheatsheet.md` with a new "Stability" section documenting valid ranges and supported aspect ratios per model.
14. **REQ-14**: **Test coverage** — every new public symbol and every non-trivial branch in the new code must be exercised by tests. This includes:
    - All three model registrations (parametric tests iterating over `[stable_image_core, stable_image_ultra, sd3_5_large]`).
    - `StabilityAspectRatio.nearest(to:)` for each of the 9 supported ratios plus midpoint edge cases.
    - `StabilityImageResolutionValidator` happy path and rejection paths.
    - `StabilityImageRequestBody` JSON encoding: the conditional omission of `negative_prompt`, `aspect_ratio`, `seed`, and `mode` (assert via decoding the encoded `Data` back into a dictionary).
    - `StabilityImageResponseBody.getGeneratedImage()` base64-decoding, including a malformed-base64 case.
    - All "not supported" rejections in `StabilityImage.getTextToImageRequestBody(...)` (`nrOfImages != 1`, non-nil `cfgScale`, non-nil `quality`, non-nil `negativePrompt` for Core/Ultra).
    - Seed boundary validation at `0` and `4_294_967_295`.
15. **REQ-15**: **Example project** — add a new standalone example package at `Examples/stability-image/` that calls `BedrockService.generateImage(...)` against `stable_image_core` in `us-west-2` and writes the resulting PNG to disk. The example must:
    - Follow the structure of existing examples (e.g. `Examples/embeddings/`): own `Package.swift`, `Sources/StabilityImage/`, executable target, `swift-bedrock-library` referenced via local path, `swift-log` as a dependency.
    - Be compilable with `swift build` from inside its directory without AWS credentials.
    - Be added to the `examples` matrix in `.github/workflows/pull_request.yml` so CI builds it on every PR.
16. **REQ-16**: **DocC documentation** — add a new article `Sources/BedrockService/Docs.docc/StabilityImageGeneration.md` (or, if reviewers prefer, a "Stability AI" section appended to the existing `ImageGeneration.md`). Either way the documentation must cover:
    - Region availability (us-west-2 only).
    - Each of the three model identifiers with a one-line description.
    - The resolution → aspect ratio mapping behavior.
    - The single-image-per-call contract and the rejected parameters (`nrOfImages > 1`, `cfgScale`, `quality`, and `negativePrompt` for Core/Ultra).
    - A working code snippet using `BedrockModel.stable_image_core`.
    - A "See Also" link from/to `ImageGeneration.md` so the new article is reachable from the existing IA.

## Non-goals

- The Stability editing endpoints (upscale, inpaint, outpaint, style transfer, sketch, structure, replace-background-and-relight) are out of scope.
- Image-to-image for `sd3-5-large` is explicitly deferred.
- Exposing `output_format` selection in the public API is deferred.
- No changes to the public `generateImage(...)` signature.
