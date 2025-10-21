# Reasoning

Access the model's reasoning process

## Overview

Reasoning capabilities allow you to see how foundation models think through problems, providing transparency into their decision-making process.

## Basic Reasoning

Enable reasoning to see the model's thought process:

```swift
let model: BedrockModel = .claudev3_7_sonnet

guard model.hasConverseModality(.reasoning) else {
    throw MyError.incorrectModality("\(model.name) does not support reasoning")
}

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Solve this math problem: If a train travels 60 mph for 2.5 hours, how far does it go?")
    .withReasoning()

let reply = try await bedrock.converse(with: builder)

if let reasoning = try? reply.getReasoningBlock() {
    print("Reasoning: \(reasoning.reasoning)")
}
print("Answer: \(reply)")
```

## Reasoning with Token Limits

Control the length of reasoning output:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Explain the causes of World War I")
    .withReasoning(maxReasoningTokens: 1024)

let reply = try await bedrock.converse(with: builder)
```

## Streaming Reasoning

See reasoning unfold in real-time:

```swift
let builder = try ConverseRequestBuilder(with model)
    .withPrompt("Plan a 7-day trip to Japan")
    .withReasoning(maxReasoningTokens: 2048)

let stream = try await bedrock.converseStream(with: builder)

var reasoningIndexes: [Int] = []
var textIndexes: [Int] = []

for try await element in stream {
    switch element {
    case .reasoning(let index, let reasoning):
        if !reasoningIndexes.contains(index) {
            reasoningIndexes.append(index)
            print("\n🤔 Reasoning: ")
        }
        print(reasoning, terminator: "")
        
    case .text(let index, let text):
        if !textIndexes.contains(index) {
            textIndexes.append(index)
            print("\n💬 Response: ")
        }
        print(text, terminator: "")
        
    case .messageComplete(_):
        print("\n")
        
    default:
        break
    }
}
```

## Complex Problem Solving

Use reasoning for multi-step problems:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("""
        A company has 150 employees. 60% work in engineering, 25% in sales, 
        and the rest in administration. If engineering gets a 10% budget increase 
        and sales gets a 5% increase, what's the total percentage increase 
        in employee-related costs?
        """)
    .withReasoning()
    .withTemperature(0.1) // Lower temperature for more focused reasoning

let reply = try await bedrock.converse(with: builder)

if let reasoning = try? reply.getReasoningBlock() {
    print("Step-by-step reasoning:")
    print(reasoning.reasoning)
    print("\nFinal answer:")
}
print(reply)
```

## Reasoning in Conversations

Maintain reasoning across conversation turns:

```swift
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("I need to choose between two job offers. Can you help me think through this?")
    .withReasoning()

var reply = try await bedrock.converse(with: builder)

if let reasoning = try? reply.getReasoningBlock() {
    print("Initial reasoning: \(reasoning.reasoning)")
}
print("Assistant: \(reply)")

// Continue with more details
builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("""
        Job A: $80k salary, great benefits, 30-minute commute, startup environment
        Job B: $75k salary, okay benefits, 10-minute commute, established company
        """)
    .withReasoning()

reply = try await bedrock.converse(with: builder)

if let reasoning = try? reply.getReasoningBlock() {
    print("Analysis reasoning: \(reasoning.reasoning)")
}
print("Assistant: \(reply)")
```

## Reasoning with Tools

Combine reasoning with function calling:

```swift
let calculatorTool = try Tool(
    name: "calculate",
    inputSchema: JSON([
        "type": "object",
        "properties": [
            "expression": ["type": "string"]
        ],
        "required": ["expression"]
    ]),
    description: "Perform mathematical calculations"
)

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Calculate the compound interest on $1000 at 5% annually for 3 years")
    .withTool(calculatorTool)
    .withReasoning()

let reply = try await bedrock.converse(with: builder)

// The model will reason about the problem and potentially use the calculator tool
if let reasoning = try? reply.getReasoningBlock() {
    print("Reasoning: \(reasoning.reasoning)")
}

if let toolUse = try? reply.getToolUse() {
    let expression: String? = toolUse.input["expression"]
    let result = calculate(expression ?? "")
    
    let finalBuilder = try ConverseRequestBuilder(from: builder, with: reply)
        .withToolResult(result)
        .withReasoning()
    
    let finalReply = try await bedrock.converse(with: finalBuilder)
    print("Final answer: \(finalReply)")
}
```

## See Also

- <doc:Converse>
- <doc:Streaming>
- <doc:Tools>