//
//  ProximityFinder.swift
//
//  Created by Till Gartner on 26.09.25.
//

import Foundation
import NaturalLanguage

struct ProximityFinder {
    let sentenceEmbedding: NLEmbedding?
    let status: String
    enum EmbeddingError: Error {
        case EmbeddingNotAvailable
    }
    
    init() throws {
        if let se = NLEmbedding.sentenceEmbedding(for: .english) {
            self.sentenceEmbedding = se
            self.status = """
            Created Sentence Embedding 👍🏼.
              Dimension: \(se.dimension),
              Vocabulary Size: \(se.vocabularySize),
              Description: \(se.description),
              Language: \(se.language?.rawValue ?? "unknown")
            """
            print (self.status)
            return
        }
        print("Could not create Sentence Embedding.")
        throw EmbeddingError.EmbeddingNotAvailable
    }
    
    private func distance(between a: String, and b: String) -> Double {
        if let se = sentenceEmbedding {
            return se.distance(between: a, and: b)
        }
         else {
            return .infinity
        }
    }
    
    func findClosest<T: Embeddable>(to question: String, in chunks: [T], k: Int = 3) -> [T] {
        var distanceCalculations = 0
        let sorted = chunks.sorted { lhs, rhs in
            let dl = distance(between: question, and: lhs.content)
            let dr = distance(between: question, and: rhs.content)
            distanceCalculations += 2
            print("\(distanceCalculations) distance calculations done.")
            return dl < dr
        }
        return Array(sorted.prefix(k))
    }
    
}
