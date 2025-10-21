# Embeddings

Generate vector embeddings for semantic analysis

## Overview

Embeddings convert text into numerical vector representations that capture semantic meaning. These vectors enable similarity comparisons, clustering, and retrieval-augmented generation (RAG) systems.

## Basic Embeddings

Generate embeddings from text:

```swift
let model: BedrockModel = .titan_embed_text_v2

guard model.hasEmbeddingsModality() else {
    throw MyError.incorrectModality("\(model.name) does not support embeddings")
}

let embeddings = try await bedrock.embed(
    "Swift is a powerful programming language",
    with: model
)

print("Generated embeddings with \(embeddings.count) dimensions")
print("First few values: \(Array(embeddings.prefix(5)))")
```

## Vector Size Control

Specify the embedding vector size:

```swift
let embeddings = try await bedrock.embed(
    "Machine learning and artificial intelligence",
    with: model,
    vectorSize: 512
)

print("Embedding dimensions: \(embeddings.count)")
```

## Semantic Similarity

Compare text similarity using embeddings:

```swift
let text1 = "The cat sat on the mat"
let text2 = "A feline rested on the rug"
let text3 = "Quantum computing uses qubits"

let embedding1 = try await bedrock.embed(text1, with: model)
let embedding2 = try await bedrock.embed(text2, with: model)
let embedding3 = try await bedrock.embed(text3, with: model)

// Calculate cosine similarity
func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
    let dotProduct = zip(a, b).map(*).reduce(0, +)
    let magnitudeA = sqrt(a.map { $0 * $0 }.reduce(0, +))
    let magnitudeB = sqrt(b.map { $0 * $0 }.reduce(0, +))
    return dotProduct / (magnitudeA * magnitudeB)
}

let similarity12 = cosineSimilarity(embedding1, embedding2)
let similarity13 = cosineSimilarity(embedding1, embedding3)

print("Similarity between text1 and text2: \(similarity12)")
print("Similarity between text1 and text3: \(similarity13)")
// text1 and text2 should have higher similarity than text1 and text3
```

## Batch Processing

Process multiple texts efficiently:

```swift
let texts = [
    "Apple is a technology company",
    "Bananas are yellow fruits", 
    "Microsoft develops software",
    "Oranges are citrus fruits",
    "Google creates search engines"
]

var embeddings: [[Double]] = []

for text in texts {
    let embedding = try await bedrock.embed(text, with: model)
    embeddings.append(embedding)
}

// Find most similar texts
func findMostSimilar(to queryIndex: Int, in embeddings: [[Double]]) -> Int {
    var maxSimilarity = -1.0
    var mostSimilarIndex = 0
    
    for (index, embedding) in embeddings.enumerated() {
        guard index != queryIndex else { continue }
        
        let similarity = cosineSimilarity(embeddings[queryIndex], embedding)
        if similarity > maxSimilarity {
            maxSimilarity = similarity
            mostSimilarIndex = index
        }
    }
    
    return mostSimilarIndex
}

let queryIndex = 0 // "Apple is a technology company"
let similarIndex = findMostSimilar(to: queryIndex, in: embeddings)
print("Most similar to '\(texts[queryIndex])': '\(texts[similarIndex])'")
```

## Document Retrieval System

Build a simple RAG system:

```swift
struct Document {
    let id: String
    let content: String
    let embedding: [Double]
}

class DocumentStore {
    private var documents: [Document] = []
    private let bedrock: BedrockService
    private let model: BedrockModel
    
    init(bedrock: BedrockService, model: BedrockModel) {
        self.bedrock = bedrock
        self.model = model
    }
    
    func addDocument(_ content: String, id: String) async throws {
        let embedding = try await bedrock.embed(content, with: model)
        let document = Document(id: id, content: content, embedding: embedding)
        documents.append(document)
    }
    
    func search(_ query: String, topK: Int = 3) async throws -> [Document] {
        let queryEmbedding = try await bedrock.embed(query, with: model)
        
        let similarities = documents.map { doc in
            (doc, cosineSimilarity(queryEmbedding, doc.embedding))
        }
        
        return similarities
            .sorted { $0.1 > $1.1 }
            .prefix(topK)
            .map { $0.0 }
    }
}

// Usage
let store = DocumentStore(bedrock: bedrock, model: model)

try await store.addDocument("Swift is a programming language developed by Apple", id: "doc1")
try await store.addDocument("Python is popular for data science and machine learning", id: "doc2")
try await store.addDocument("JavaScript runs in web browsers and Node.js", id: "doc3")

let results = try await store.search("Apple programming language")
for doc in results {
    print("Found: \(doc.content)")
}
```

## Text Clustering

Group similar texts using embeddings:

```swift
struct TextCluster {
    let centroid: [Double]
    var texts: [String]
    var embeddings: [[Double]]
}

func kMeansClustering(texts: [String], embeddings: [[Double]], k: Int, iterations: Int = 10) -> [TextCluster] {
    // Simple k-means implementation
    var clusters = Array(0..<k).map { _ in
        TextCluster(
            centroid: embeddings.randomElement()!,
            texts: [],
            embeddings: []
        )
    }
    
    for _ in 0..<iterations {
        // Clear clusters
        for i in 0..<clusters.count {
            clusters[i].texts.removeAll()
            clusters[i].embeddings.removeAll()
        }
        
        // Assign texts to nearest cluster
        for (textIndex, embedding) in embeddings.enumerated() {
            var minDistance = Double.infinity
            var nearestCluster = 0
            
            for (clusterIndex, cluster) in clusters.enumerated() {
                let distance = 1.0 - cosineSimilarity(embedding, cluster.centroid)
                if distance < minDistance {
                    minDistance = distance
                    nearestCluster = clusterIndex
                }
            }
            
            clusters[nearestCluster].texts.append(texts[textIndex])
            clusters[nearestCluster].embeddings.append(embedding)
        }
        
        // Update centroids
        for i in 0..<clusters.count {
            if !clusters[i].embeddings.isEmpty {
                let dimensions = clusters[i].embeddings[0].count
                var newCentroid = Array(repeating: 0.0, count: dimensions)
                
                for embedding in clusters[i].embeddings {
                    for j in 0..<dimensions {
                        newCentroid[j] += embedding[j]
                    }
                }
                
                for j in 0..<dimensions {
                    newCentroid[j] /= Double(clusters[i].embeddings.count)
                }
                
                clusters[i] = TextCluster(
                    centroid: newCentroid,
                    texts: clusters[i].texts,
                    embeddings: clusters[i].embeddings
                )
            }
        }
    }
    
    return clusters
}
```

## Model Capabilities

Check embedding model features:

```swift
if let embeddingModality = model.modality as? EmbeddingsModality {
    let params = embeddingModality.getEmbeddingsParameters()
    
    if let vectorSizes = params.vectorSize.allowedValues {
        print("Supported vector sizes: \(vectorSizes)")
    }
    
    print("Default vector size: \(params.vectorSize.defaultValue)")
}
```

## Use Cases

Embeddings are useful for:

- **Semantic Search**: Find documents similar to a query
- **Recommendation Systems**: Suggest similar content
- **Text Classification**: Group texts by topic
- **Duplicate Detection**: Find similar or duplicate content
- **RAG Systems**: Retrieve relevant context for generation
- **Clustering**: Organize large text collections
- **Anomaly Detection**: Identify unusual text patterns

## See Also

- <doc:TextGeneration>
- <doc:Converse>