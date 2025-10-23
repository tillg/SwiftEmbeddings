import Foundation
import NaturalLanguage

actor EmbeddingStore {
    private let model: NLContextualEmbedding
    private var chunks: [Chunk] = []
    private var vectorCache: [String: [Double]] = [:]
    private var questionVectorCache: [String: [Double]] = [:]

    init(model: NLContextualEmbedding) {
        self.model = model
    }

    func loadChunksNaive(_ newChunks: [Chunk]) async {
        self.chunks = newChunks

        await withTaskGroup(of: (String, [Double]?).self) { group in
            for chunk in newChunks {
                group.addTask {
                    let chunkId = await MainActor.run { chunk.id }
                    let chunkContent = await MainActor.run { chunk.content }
                    do {
                        let vector = try await self.computeVectorNaive(for: chunkContent)
                        return (chunkId, vector)
                    } catch {
                        print("Failed to compute vector for chunk \(chunkId): \(error)")
                        return (chunkId, nil)
                    }
                }
            }

            for await (id, vector) in group {
                if let vector = vector {
                    vectorCache[id] = vector
                }
            }
        }
    }
    
    func loadChunksDSP(_ newChunks: [Chunk]) async {
        self.chunks = newChunks

        await withTaskGroup(of: (String, [Double]?).self) { group in
            for chunk in newChunks {
                group.addTask {
                    let chunkId = await MainActor.run { chunk.id }
                    let chunkContent = await MainActor.run { chunk.content }
                    do {
                        let vector = try await self.computeVectorDSP(for: chunkContent)
                        return (chunkId, vector)
                    } catch {
                        print("Failed to compute vector for chunk \(chunkId): \(error)")
                        return (chunkId, nil)
                    }
                }
            }

            for await (id, vector) in group {
                if let vector = vector {
                    vectorCache[id] = vector
                }
            }
        }
    }
    private func computeVectorNaive(for content: String) async throws -> [Double] {
        return try await MainActor.run {
            try self.model.vectorNaive(for: content, language: nil)
        }
    }

    private func computeVectorDSP(for content: String) async throws -> [Double] {
        return try await MainActor.run {
            try self.model.vectorDSP(for: content, language: nil)
        }
    }

    func closest(to question: String, k: Int = 3) async -> [Chunk] {
        guard !chunks.isEmpty else { return [] }

        let questionVector: [Double]
        if let cached = questionVectorCache[question] {
            questionVector = cached
        } else {
            do {
                questionVector = try await computeVectorNaive(for: question)
                questionVectorCache[question] = questionVector
            } catch {
                fatalError("Failed to compute question vector: \(error)")
            }
        }

        // Calculate all distances between the question vector and the chunk vectors
        var chunksWithDistances: [(chunk: Chunk, distance: Double)] = []
        await timerTrack("Calculating distances") {
            for chunk in chunks {
                guard let chunkVector = await vectorCache[chunk.id] else {
                    fatalError("Missing vector in cache.")
                }
                let distance = await MainActor.run {
                    let cosineSim = cosineSimilarityNaive(questionVector, chunkVector) ?? 0.0
                    return 1 - cosineSim
                }
                chunksWithDistances.append((chunk, distance))
            }
        }
        await timerReport("Calculating distances")
        
        var sorted: [(chunk: Chunk, distance: Double)] = []
        await timerTrack("Sorting chunks based on pre-calculated distances") {
             sorted = chunksWithDistances.sorted { $0.distance < $1.distance }
        }
        await timerReport("Sorting chunks based on pre-calculated distances")
        return Array(sorted.prefix(k).map { $0.chunk })
    }
    
    func closestDSP(to question: String, k: Int = 3) async -> [Chunk] {
        guard !chunks.isEmpty else { return [] }

        let questionVector: [Double]
        if let cached = questionVectorCache[question] {
            questionVector = cached
        } else {
            do {
                questionVector = try await computeVectorDSP(for: question)
                questionVectorCache[question] = questionVector
            } catch {
                fatalError("Failed to compute question vector: \(error)")
            }
        }

        // Calculate all distances between the question vector and the chunk vectors
        var chunksWithDistances: [(chunk: Chunk, distance: Double)] = []
        await timerTrack("Calculating distances") {
            for chunk in chunks {
                guard let chunkVector = await vectorCache[chunk.id] else {
                    fatalError("Missing vector in cache.")
                }
                let distance = await MainActor.run {
                    let cosineSim = cosineSimilarityNaive(questionVector, chunkVector) ?? 0.0
                    return 1 - cosineSim
                }
                chunksWithDistances.append((chunk, distance))
            }
        }
        await timerReport("Calculating distances")
        
        var sorted: [(chunk: Chunk, distance: Double)] = []
        await timerTrack("Sorting chunks based on pre-calculated distances") {
             sorted = chunksWithDistances.sorted { $0.distance < $1.distance }
        }
        await timerReport("Sorting chunks based on pre-calculated distances")
        return Array(sorted.prefix(k).map { $0.chunk })
    }

    func invalidateQuestionCache() {
        questionVectorCache.removeAll(keepingCapacity: true)
    }

    func invalidateAll() {
        vectorCache.removeAll(keepingCapacity: true)
        questionVectorCache.removeAll(keepingCapacity: true)
    }
}
