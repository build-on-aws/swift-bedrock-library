# Tools

Enable function calling with foundation models

## Overview

Tools allow foundation models to call external functions, enabling them to access real-time data, perform calculations, and interact with external systems.

## Basic Tool Usage

Define and use a simple tool:

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality(.toolUse) else {
    throw MyError.incorrectModality("\(model.name) does not support tools")
}

// Define the tool's input schema
let inputSchema = JSON([
    "type": "object",
    "properties": [
        "sign": [
            "type": "string",
            "description": "Radio station call sign (e.g., WZPZ, WKRP)"
        ]
    ],
    "required": ["sign"]
])

// Create the tool
let tool = try Tool(
    name: "top_song",
    inputSchema: inputSchema,
    description: "Get the most popular song on a radio station"
)

// Use the tool in a conversation
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("What is the most popular song on WZPZ?")
    .withTool(tool)

var reply = try await bedrock.converse(with: builder)

// Handle tool use request
if let toolUse = try? reply.getToolUse() {
    let sign: String? = toolUse.input["sign"]
    let result = getMostPopularSong(for: sign ?? "")
    
    builder = try ConverseRequestBuilder(from: builder, with: reply)
        .withToolResult(result)
    
    reply = try await bedrock.converse(with: builder)
}

print("Assistant: \(reply)")
```

## Multiple Tools

Add multiple tools to expand capabilities:

```swift
let weatherTool = try Tool(
    name: "get_weather",
    inputSchema: JSON([
        "type": "object",
        "properties": [
            "location": ["type": "string", "description": "City name"]
        ],
        "required": ["location"]
    ]),
    description: "Get current weather for a location"
)

let calculatorTool = try Tool(
    name: "calculate",
    inputSchema: JSON([
        "type": "object", 
        "properties": [
            "expression": ["type": "string", "description": "Math expression to evaluate"]
        ],
        "required": ["expression"]
    ]),
    description: "Perform mathematical calculations"
)

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("What's the weather in Paris and what's 15 * 23?")
    .withTools([weatherTool, calculatorTool])
```

## Tool Result Types

Return different types of data as tool results:

```swift
// String result
builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withToolResult("Sunny, 22°C")

// JSON result
let weatherData = ["temperature": 22, "condition": "sunny"]
builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withToolResult(weatherData)

// Custom Codable type
struct WeatherInfo: Codable {
    let temperature: Int
    let condition: String
}

let weather = WeatherInfo(temperature: 22, condition: "sunny")
builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withToolResult(weather)
```

## Interactive Tool Usage

Build an interactive system with multiple tool calls:

```swift
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Introduce yourself and mention your available tools")
    .withTools([weatherTool, calculatorTool])

while true {
    let reply = try await bedrock.converse(with: builder)
    
    if let toolUse = try? reply.getToolUse() {
        let result = handleToolUse(toolUse)
        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withToolResult(result)
    } else {
        print("Assistant: \(reply)")
        print("You: ")
        guard let prompt = readLine(), prompt != "quit" else { break }
        
        builder = try ConverseRequestBuilder(from: builder, with: reply)
            .withPrompt(prompt)
    }
}

func handleToolUse(_ toolUse: ToolUseBlock) -> String {
    switch toolUse.name {
    case "get_weather":
        let location: String? = toolUse.input["location"]
        return getWeather(for: location ?? "")
    case "calculate":
        let expression: String? = toolUse.input["expression"]
        return calculate(expression ?? "")
    default:
        return "Unknown tool"
    }
}
```

## Streaming with Tools

Tools work seamlessly with streaming:

```swift
let stream = try await bedrock.converseStream(with: builder)

for try await element in stream {
    switch element {
    case .text(_, let text):
        print(text, terminator: "")
    case .toolUse(let index, let toolUse):
        print("Tool requested: \(toolUse.name)")
    case .messageComplete(let message):
        // Handle tool use from complete message
        break
    default:
        break
    }
}
```

## JSON Schema Helper

The `JSON` struct provides convenient schema creation:

```swift
// From dictionary
let schema = JSON([
    "type": "object",
    "properties": [
        "query": ["type": "string"]
    ]
])

// From JSON string
let jsonString = """
{
    "type": "object",
    "properties": {
        "location": {"type": "string"},
        "units": {"type": "string", "enum": ["celsius", "fahrenheit"]}
    },
    "required": ["location"]
}
"""
let schema = try JSON(from: jsonString)

// Access values
let location: String? = toolUse.input["location"]
let units: String? = toolUse.input["units"]
```

## See Also

- <doc:Converse>
- <doc:Streaming>