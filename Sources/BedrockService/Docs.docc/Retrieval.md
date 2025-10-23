# Knowledge Base Retrieval

Retrieve information from Amazon Bedrock knowledge bases for RAG applications

## Overview

The Knowledge Base Retrieval feature allows you to query Amazon Bedrock knowledge bases to retrieve relevant information for Retrieval-Augmented Generation (RAG) applications. This enables you to ground your AI responses with specific, up-to-date information from your own data sources.

## Basic Retrieval

Retrieve information from a knowledge base:

```swift
let result = try await bedrock.retrieve(
    knowledgeBaseId: "your-knowledge-base-id",
    retrievalQuery: "What is the company policy on remote work?"
)

// Get the best matching result
if let bestMatch = result.bestMatch() {
    print("Best match: \(bestMatch.content?.text ?? "No content")")
    print("Relevance score: \(bestMatch.score ?? 0)")
}

// Access all results
if let allResults = result.results {
    for (index, result) in allResults.enumerated() {
        print("Result \(index + 1): \(result.content?.text ?? "No content")")
    }
}
```

## Controlling Results

Specify the number of results to retrieve:

```swift
let result = try await bedrock.retrieve(
    knowledgeBaseId: "your-knowledge-base-id",
    retrievalQuery: "company benefits",
    numberOfResults: 5
)
```

## Working with Results

The `RetrieveResult` wrapper provides convenient access to the retrieved information:

```swift
let result = try await bedrock.retrieve(
    knowledgeBaseId: "kb-123",
    retrievalQuery: "product specifications"
)

// Get the highest-scoring result
let bestMatch = result.bestMatch()

// Access all results with scores and metadata
for retrievalResult in result.results ?? [] {
    if let content = retrievalResult.content?.text {
        print("Content: \(content)")
    }
    
    if let score = retrievalResult.score {
        print("Relevance Score: \(score)")
    }
    
    if let source = retrievalResult.location?.s3Location?.uri {
        print("Source: \(source)")
    }
}
```

## JSON Export for LLM Context

Export results as JSON to pass to language models:

```swift
let result = try await bedrock.retrieve(
    knowledgeBaseId: "kb-123",
    retrievalQuery: "user documentation"
)

// Convert to JSON for LLM context
let jsonContext = try result.toJSON()

// Use in a conversation
let builder = try ConverseRequestBuilder(with: .nova_lite)
    .withSystemPrompts(["Use this context to answer questions: \(jsonContext)"])
    .withPrompt("How do I reset my password?")

let reply = try await bedrock.converse(with: builder)
```

## RAG Pattern Example

Combine retrieval with conversation for a complete RAG implementation:

```swift
func answerWithContext(question: String, knowledgeBaseId: String) async throws -> String {
    // 1. Retrieve relevant information
    let retrievalResult = try await bedrock.retrieve(
        knowledgeBaseId: knowledgeBaseId,
        retrievalQuery: question,
        numberOfResults: 3
    )
    
    // 2. Prepare context from results
    let context = try retrievalResult.toJSON()
    
    // 3. Generate answer using retrieved context
    let builder = try ConverseRequestBuilder(with: .nova_lite)
        .withSystemPrompts([
            "Answer the user's question using only the provided context.",
            "Context: \(context)"
        ])
        .withPrompt(question)
    
    let reply = try await bedrock.converse(with: builder)
    return reply
}

// Usage
let answer = try await answerWithContext(
    question: "What are the system requirements?",
    knowledgeBaseId: "your-kb-id"
)
```

## See Also

- <doc:Converse>
- <doc:Tools>