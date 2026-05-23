# Swift 6 Project Guidelines

## Language & Platform

- Always prefer Swift. Fall back to Objective-C, C, or C++ only when necessary.
- Favor Apple frameworks and APIs already available on device.
- Use official platform names: iOS, iPadOS, macOS, watchOS, visionOS.
- Pay attention to platform clues — don't suggest iOS-only APIs for a Mac app.

## Swift 6 Concurrency

- Prefer Swift Concurrency (async/await, actors) over Dispatch or Combine.
- Use structured concurrency (`async let`, `withTaskGroup`) over unstructured `Task` when possible.
- Use `Task.detached` only with a documented reason.
- Match a `Task`'s entry isolation to its synchronous prefix — start on `@MainActor` only when the prefix truly needs it; otherwise use `Task { @concurrent in ... }` and hop back with `MainActor.run`.
- Don't apply `@MainActor` as a blanket fix — justify that the code is truly UI-bound.
- Prefer `actor` or `Mutex` over locks/queues for shared mutable state.
- Prefer immutable values and explicit boundaries over `@unchecked Sendable`.
- If recommending `@preconcurrency`, `@unchecked Sendable`, or `nonisolated(unsafe)`, require a safety invariant and a removal plan.

## Before Fixing Concurrency Issues

1. Check `Package.swift` for: Swift language mode, strict concurrency level, default isolation, upcoming features.
2. Capture the exact diagnostic and offending symbol.
3. Determine the isolation boundary (`@MainActor`, custom actor, `nonisolated`).
4. Optimize for the smallest safe change — don't refactor unrelated architecture.

## Testing

- Always use Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`) over XCTest.
- Use `swift test` to run tests.

```swift
import Testing

@Suite("Example")
struct ExampleTests {
    @Test("Adding numbers")
    func addNumbers() async throws {
        #expect(3 + 7 == 10)
    }

    @Test
    func optionalUnwrap() async throws {
        let value: Int? = 42
        let unwrapped = try #require(value)
        #expect(unwrapped == 42)
    }
}
```

## Tooling

- Use `swift format` (not `swift-format`) for formatting.
- Use `swift build` and `swift test` for building and testing.
- Run SPM commands (`swift build`, `swift test`, `swift package`) sequentially — never in parallel. SPM applies a directory-level lock, so concurrent invocations will timeout.

## API Design (Swift conventions)

- Clarity at the point of use is the top priority.
- Name methods by their side-effects: noun phrases for non-mutating, imperative verbs for mutating.
- Use `lowerCamelCase` for functions/properties, `UpperCamelCase` for types/protocols.
- Omit needless words; name parameters by role, not type.
- Begin factory methods with `make`.
- Boolean properties read as assertions: `isEmpty`, `isValid`.

## Code Proposals

- When proposing changes to an existing file, reproduce the entire file (no elisions).
- Mark revised files as ` ```swift:Filename.swift `.
- For new files or general examples, use plain ` ```swift ` blocks.
