# Documents

Process documents with foundation models

## Overview

Document processing allows you to send PDF, text, and other document formats to foundation models for analysis, summarization, and question answering.

## Basic Document Processing

Send a document for analysis:

```swift
let model: BedrockModel = .nova_lite

guard model.hasConverseModality(.document) else {
    throw MyError.incorrectModality("\(model.name) does not support documents")
}

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Can you give me a summary of this chapter?")
    .withDocument(name: "Chapter 1", format: .pdf, source: base64EncodedDocument)

let reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")
```

## Supported Document Formats

BedrockService supports various document formats:
- PDF (`.pdf`)
- Plain text (`.txt`)
- Markdown (`.md`)
- CSV (`.csv`)
- Microsoft Word (`.docx`)

## Document with Parameters

Combine document processing with inference parameters:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Summarize the key points from this document")
    .withDocument(name: "Report", format: .pdf, source: base64EncodedDocument)
    .withMaxTokens(512)
    .withTemperature(0.4)

let reply = try await bedrock.converse(with: builder)
```

## Multi-turn Document Conversations

Continue conversations about the same document:

```swift
var builder = try ConverseRequestBuilder(with: model)
    .withPrompt("What are the main conclusions in this research paper?")
    .withDocument(name: "Research Paper", format: .pdf, source: base64EncodedDocument)

var reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")

// Ask follow-up questions without re-sending the document
builder = try ConverseRequestBuilder(from: builder, with: reply)
    .withPrompt("What methodology did they use?")

reply = try await bedrock.converse(with: builder)
print("Assistant: \(reply)")
```

## Using DocumentBlock

Create `DocumentBlock` objects for more control:

```swift
let documentBlock = DocumentBlock(
    name: "Financial Report Q4",
    format: .pdf,
    source: base64EncodedDocument
)

let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Analyze the financial trends in this report")
    .withDocument(documentBlock)
```

## Document Analysis Tasks

Common document processing tasks:

### Summarization
```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Provide a concise summary of this document")
    .withDocument(name: "Article", format: .pdf, source: documentData)
```

### Question Answering
```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("What is the author's main argument about climate change?")
    .withDocument(name: "Climate Paper", format: .pdf, source: documentData)
```

### Translation
```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Translate this document to French")
    .withDocument(name: "Contract", format: .pdf, source: documentData)
```

## Streaming with Documents

Document processing works with streaming responses:

```swift
let builder = try ConverseRequestBuilder(with: model)
    .withPrompt("Analyze this legal document and highlight key clauses")
    .withDocument(name: "Contract", format: .pdf, source: base64EncodedDocument)

let stream = try await bedrock.converseStream(with: builder)

for try await element in stream {
    switch element {
    case .text(_, let text):
        print(text, terminator: "")
    case .messageComplete(_):
        print("\n")
    default:
        break
    }
}
```

## See Also

- <doc:Converse>
- <doc:Vision>
- <doc:Streaming>