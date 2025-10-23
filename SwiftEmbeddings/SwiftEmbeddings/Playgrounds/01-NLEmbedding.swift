//
//  01-NLEmbedding.swift
//
//  Created by Till Gartner on 01.10.25.
//

import NaturalLanguage
import Playgrounds


#Playground("Basic embedding & distance")
{
    let question = "What is a protocol?"
    let potentialAnswer = """
    A protocol defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be adopted by a class, structure, or enumeration to provide an actual implementation of those requirements. Any type that satisfies the requirements of a protocol is said to conform to that protocol.
    In addition to specifying requirements that conforming types must implement, you can extend a protocol to implement some of these requirements or to implement additional functionality that conforming types can take advantage of.
    """
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
        guard let vector = sentenceEmbedding.vector(for: question) else {
            fatalError("Cannot create vector")
        }
        let distance = sentenceEmbedding.distance(between: question, and: potentialAnswer)
        print("Distance: \(distance.description)")
    }
}


#Playground("Calc Embeddings")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    
    print("Calculating embedding vector for \(chunks.count) chunks")
    
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {

        timerTrack("Calculating vectors with NLEmbedding") {
            for chunk in chunks {
                _ = sentenceEmbedding.vector(for: chunk.content)
            }
        }
        timerReport("Calculating vectors with NLEmbedding")
    }
}


#Playground("Calc Distances")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    
    print("Calculating distance between \(chunks.count) pairs of sentences")
    
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {

        await timerTrack("Calculating distances with NLEmbedding")  {
            for chunk in chunks {
                _ = await sentenceEmbedding.distance(between: chunk.content, and: chunks.randomElement()!.content)
            }
        }
        timerReport("Calculating distances with NLEmbedding")
    }
}

#Playground("Calc closest in arry")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    print("Calculating the closest chunks in an array of \(chunks.count) chunks")

    func findClosest<T: Embeddable>(to question: String, in chunks: [T], k: Int = 3) -> [T] {
        guard let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) else {
            // Fallback if embedding is unavailable
            return Array(chunks.prefix(k))
        }
        var distanceCalculations = 0
        let sorted = chunks.sorted { lhs, rhs in
            let dl = sentenceEmbedding.distance(between: question, and: lhs.content)
            let dr = sentenceEmbedding.distance(between: question, and: rhs.content)
            distanceCalculations += 2
            return dl < dr
        }
        print("\(distanceCalculations) distance calculations done.")
        return Array(sorted.prefix(k))
    }
    
    timerTrack("Calculating the closest chunks in an array of chunks") {
        let closeOnes = findClosest(to: "What is the capital of France?", in: chunks)
    }
    timerReport("Calculating the closest chunks in an array of chunks")
}

