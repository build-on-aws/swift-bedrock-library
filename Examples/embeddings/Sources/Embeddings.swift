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

import BedrockService
import Foundation

/// # Text Embeddings Example
///
/// This example demonstrates how to use Amazon Bedrock's text embedding capabilities
/// to convert text into numerical vectors and perform similarity comparisons.
///
/// ## What are embeddings?
/// Text embeddings are numerical representations of text that capture semantic meaning.
/// Similar texts will have similar embedding vectors, allowing us to measure how
/// related different pieces of text are to each other.
@main
struct Embeddings {
    /// The Bedrock service client for making API calls
    let bedrock: BedrockService

    /// The embedding model - Titan Text Embeddings V2 converts text into 1024-dimensional vectors
    let model = BedrockModel.titan_embed_text_v2

    /// Main entry point that runs all embedding examples
    static func main() async throws {
        // Initialize the Bedrock service in US East 1 region
        let b = try await BedrockService(region: .useast1)
        let e = Embeddings(bedrock: b)

        // Run each example in sequence
        try await e.simple()
        try await e.batch()
        try await e.doc()
    }

    /// Demonstrates basic text similarity using embeddings
    ///
    /// This example shows how to convert text into embedding vectors and calculate
    /// similarity between different texts. The first two sentences should be more
    /// similar than the first and third, even though they use different words.
    func simple() async throws {

        // Three test sentences: two similar, one different
        let text1 = "The cat sat on the mat"
        let text2 = "A feline rested on the rug"  // Similar meaning, different words
        let text3 = "Quantum computing uses qubits"  // Completely different topic

        // Convert each text into an embedding vector (array of numbers)
        let embedding1 = try await bedrock.embed(text1, with: model)
        let embedding2 = try await bedrock.embed(text2, with: model)
        let embedding3 = try await bedrock.embed(text3, with: model)

        // Calculate how similar the texts are using cosine similarity
        // Values range from -1 (opposite) to 1 (identical)
        let similarity12 = cosineSimilarity(embedding1, embedding2)
        let similarity13 = cosineSimilarity(embedding1, embedding3)

        print("Similarity between text1 and text2: \(similarity12)")
        print("Similarity between text1 and text3: \(similarity13)")
    }

    /// Calculates cosine similarity between two embedding vectors
    ///
    /// Cosine similarity measures the angle between two vectors, focusing on direction
    /// rather than magnitude. Perfect for comparing embeddings.
    ///
    /// - Parameters:
    ///   - a: First embedding vector
    ///   - b: Second embedding vector
    /// - Returns: Similarity score from -1 (opposite) to 1 (identical)
    func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
        // Calculate dot product (multiply corresponding elements and sum)
        let dotProduct = zip(a, b).map { $0 * $1 }.reduce(0, +)
        // Calculate the magnitude (length) of each vector
        let magnitudeA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        // Cosine similarity = dot product / (magnitude A × magnitude B)
        return dotProduct / (magnitudeA * magnitudeB)
    }

    /// Demonstrates batch processing and finding similar texts in a collection
    ///
    /// This example shows how to process multiple texts and find the most similar
    /// text to a given query. Useful for grouping similar content.
    func batch() async throws {
        // Sample texts: mix of tech companies and fruits
        let texts = [
            "Apple is a technology company",
            "Bananas are yellow fruits",
            "Microsoft develops software",
            "Oranges are citrus fruits",
            "Google creates search engines",
        ]

        var embeddings: [[Double]] = []

        // Convert each text to its embedding vector
        for text in texts {
            let embedding = try await bedrock.embed(text, with: model)
            embeddings.append(embedding)
        }

        /// Finds the most similar text to a given query text
        func findMostSimilar(to queryIndex: Int, in embeddings: [[Double]]) -> Int {
            var maxSimilarity = -1.0  // Start with lowest possible similarity
            var mostSimilarIndex = 0

            // Compare query text with all other texts
            for (index, embedding) in embeddings.enumerated() {
                guard index != queryIndex else { continue }  // Skip comparing with itself

                let similarity = cosineSimilarity(embeddings[queryIndex], embedding)
                if similarity > maxSimilarity {
                    maxSimilarity = similarity
                    mostSimilarIndex = index
                }
            }

            return mostSimilarIndex
        }

        // Find what's most similar to "Apple is a technology company"
        let queryIndex = 0
        let similarIndex = findMostSimilar(to: queryIndex, in: embeddings)
        print("Most similar to '\(texts[queryIndex])': '\(texts[similarIndex])'")

    }
    /// Demonstrates document storage and semantic search
    ///
    /// This example shows how to build a simple document database with embeddings
    /// and perform semantic search (find by meaning, not exact words).
    func doc() async throws {

        // Create a document store that can search by meaning
        let store = DocumentStore(bedrock: bedrock, model: model, similaryFn: cosineSimilarity)

        // Add some programming-related documents
        try await store.addDocument("Swift is a programming language developed by Apple", id: "doc1")
        try await store.addDocument(
            "Python is popular for data science and machine learning",
            id: "doc2"
        )
        try await store.addDocument("JavaScript runs in web browsers and Node.js", id: "doc3")

        // Search using natural language - notice we don't use exact words
        let results = try await store.search("Programming language for iOS", topK: 1)
        for doc in results {
            print("Found: \(doc.content)")
        }
    }
}

/// Represents a document with its content and embedding vector
///
/// Stores both the original text and its numerical representation for fast searches.
struct Document {
    /// Unique identifier for the document
    let id: String
    /// The original text content
    let content: String
    /// The embedding vector representing the document's meaning
    let embedding: [Double]
}

/// A simple in-memory document store with semantic search capabilities
///
/// Demonstrates how to build a basic vector database that stores documents
/// with their embeddings and searches by converting queries to embeddings.
class DocumentStore {
    /// Function type for calculating similarity between embeddings
    typealias DistanceFn = ([Double], [Double]) -> Double

    private var documents: [Document] = []
    private let bedrock: BedrockService
    private let model: BedrockModel
    private let distanceFn: DistanceFn

    /// Initialize the document store with a Bedrock service and similarity function
    init(bedrock: BedrockService, model: BedrockModel, similaryFn: @escaping DistanceFn) {
        self.bedrock = bedrock
        self.model = model
        self.distanceFn = similaryFn
    }

    /// Adds a new document to the store
    ///
    /// The document's text is converted to an embedding and stored for future searches.
    func addDocument(_ content: String, id: String) async throws {
        // Convert the document text to an embedding vector
        let embedding = try await bedrock.embed(content, with: model)
        let document = Document(id: id, content: content, embedding: embedding)
        documents.append(document)
    }

    /// Searches for documents similar to the query
    ///
    /// Performs semantic search by converting the query to an embedding and
    /// comparing it with all stored document embeddings.
    ///
    /// - Parameters:
    ///   - query: The search query (natural language)
    ///   - topK: Maximum number of results to return
    /// - Returns: Array of most similar documents, sorted by relevance
    func search(_ query: String, topK: Int = 3) async throws -> [Document] {
        // Convert the search query to an embedding
        let queryEmbedding = try await bedrock.embed(query, with: model)

        // Calculate similarity between query and each document
        let similarities = documents.map { doc in
            (doc, distanceFn(queryEmbedding, doc.embedding))
        }

        // Sort by similarity (highest first) and return top results
        return
            similarities
            .sorted { $0.1 > $1.1 }  // Sort by similarity score descending
            .prefix(topK)  // Take only the top K results
            .map { $0.0 }  // Extract just the documents
    }
}
