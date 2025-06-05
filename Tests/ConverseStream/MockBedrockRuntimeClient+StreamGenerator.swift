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

@preconcurrency import AWSBedrockRuntime

extension MockBedrockRuntimeClient {
    // returns "Hello, your prompt was: \(textPrompt)"
    package func getTextStream(
        _ textPrompt: String = "Streaming Text"
    ) -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block delta (first part)
            let contentBlockDelta1 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "Hello, "
            )
            let contentBlockDeltaEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent1))

            // Content block delta (second part)
            let contentBlockDelta2 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "your prompt "
            )
            let contentBlockDeltaEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent2))

            // Content block delta (third part)
            let contentBlockDelta3 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "was: "
            )
            let contentBlockDeltaEvent3 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta3
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent3))

            // Content block delta (third part)
            let contentBlockDelta4 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                textPrompt
            )
            let contentBlockDeltaEvent4 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta4
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent4))

            // Content block stop
            let contentBlockStopEvent = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: .endTurn
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }

    package func getToolUseStream(
        for toolName: String
    ) -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block start
            let contentBlockStartEvent = BedrockRuntimeClientTypes.ContentBlockStartEvent(
                contentBlockIndex: 0,
                start: .tooluse(BedrockRuntimeClientTypes.ToolUseBlockStart(name: toolName, toolUseId: "tooluseid"))
            )
            continuation.yield(.contentblockstart(contentBlockStartEvent))

            // Content block delta
            let contentBlockDelta = BedrockRuntimeClientTypes.ContentBlockDelta.tooluse(
                BedrockRuntimeClientTypes.ToolUseBlockDelta(input: "{\"key\": \"ABC\"}")
            )
            let contentBlockDeltaEvent = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDelta
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent))

            // Content block stop
            let contentBlockStopEvent = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: nil
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }

    package func getReasoningStream(
        _ textPrompt: String = "Streaming Text"
    ) -> AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> {
        AsyncThrowingStream<BedrockRuntimeClientTypes.ConverseStreamOutput, Error> { continuation in
            // Message start
            let messageStartEvent = BedrockRuntimeClientTypes.MessageStartEvent(
                role: .assistant
            )
            continuation.yield(.messagestart(messageStartEvent))

            // Content block delta (reasoning - first part)
            let contentBlockDeltaReasoning1 = BedrockRuntimeClientTypes.ContentBlockDelta.reasoningcontent(
                BedrockRuntimeClientTypes.ReasoningContentBlockDelta.text("reasoning ")
            )
            let contentBlockDeltaReasoningEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDeltaReasoning1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaReasoningEvent1))

            // Content block delta (reasoning - second part)
            let contentBlockDeltaReasoning2 = BedrockRuntimeClientTypes.ContentBlockDelta.reasoningcontent(
                BedrockRuntimeClientTypes.ReasoningContentBlockDelta.text("text ")
            )
            let contentBlockDeltaReasoningEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 0,
                delta: contentBlockDeltaReasoning2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaReasoningEvent2))

            // Content block stop
            let contentBlockStopEvent = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 0
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent))

            // Content block delta (first part)
            let contentBlockDelta1 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "Hello, "
            )
            let contentBlockDeltaEvent1 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta1
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent1))

            // Content block delta (second part)
            let contentBlockDelta2 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "your prompt "
            )
            let contentBlockDeltaEvent2 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta2
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent2))

            // Content block delta (third part)
            let contentBlockDelta3 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                "was: "
            )
            let contentBlockDeltaEvent3 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta3
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent3))

            // Content block delta (third part)
            let contentBlockDelta4 = BedrockRuntimeClientTypes.ContentBlockDelta.text(
                textPrompt
            )
            let contentBlockDeltaEvent4 = BedrockRuntimeClientTypes.ContentBlockDeltaEvent(
                contentBlockIndex: 1,
                delta: contentBlockDelta4
            )
            continuation.yield(.contentblockdelta(contentBlockDeltaEvent4))

            // Content block stop
            let contentBlockStopEvent1 = BedrockRuntimeClientTypes.ContentBlockStopEvent(
                contentBlockIndex: 1
            )
            continuation.yield(.contentblockstop(contentBlockStopEvent1))

            // Message stop
            let messageStopEvent = BedrockRuntimeClientTypes.MessageStopEvent(
                additionalModelResponseFields: nil,
                stopReason: nil
            )
            continuation.yield(.messagestop(messageStopEvent))

            continuation.finish()
        }
    }
}
