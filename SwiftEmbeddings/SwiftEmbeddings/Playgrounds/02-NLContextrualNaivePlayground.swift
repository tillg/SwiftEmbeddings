
//
//  NLEmbedding.swift
//
//  Created by Till Gartner on 01.10.25.
//

import NaturalLanguage
import Playgrounds


#Playground("Naive embedding")
{
    let question = "How can I extend a protocol?"
    
    guard let contextModel = NLContextualEmbedding(language: .english)
    else {
        fatalError("Cannot create the NLContextualEmbedding")
    }
    
    let status = """
    Created Contextual Embedding 👍🏼.
      Dimension: \(contextModel.dimension),
      Description: \(contextModel.description),
      Model Identifier: \(contextModel.modelIdentifier)
    """
    print (status)
    
    if contextModel.hasAvailableAssets {
        print("Loading assets...")
        try await contextModel.requestAssets()
        print("Assets requested 👍🏼")
    }
    try contextModel.load()
    
    let result = try contextModel.embeddingResult(for: question, language: nil)
    let vector = result.meanVectorNaive()
}



#Playground("Calc Just Embeddings with NLContextualEmbedding")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    
    print("Calculating embedding vectors for \(chunks.count) chunks")
    if let contextModel = NLContextualEmbedding(language: .english)
    {
        let status = """
        Created Contextual Embedding 👍🏼.
          Dimension: \(contextModel.dimension),
          Description: \(contextModel.description),
          Model Identifier: \(contextModel.modelIdentifier)
        """
        print (status)
        
        if contextModel.hasAvailableAssets {
            print("Loading assets...")
            try await contextModel.requestAssets()
            print("Assets requested 👍🏼")
        }
        try contextModel.load()
        
        try timerTrack("Calculating embedding vectors") {
            for chunk in chunks {
                _ = try contextModel.embeddingResult(for: chunk.content, language: nil)
            }
        }
        timerReport("Calculating embedding vectors")
    }

}

#Playground("Calc Embeddings Naive")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    
    print("Calculating embedding vector for \(chunks.count) chunks the naive way")
    if let contextModel = NLContextualEmbedding(language: .english)
    {
        let status = """
        Created Contextual Embedding 👍🏼.
          Dimension: \(contextModel.dimension),
          Description: \(contextModel.description),
          Model Identifier: \(contextModel.modelIdentifier)
        """
        print (status)
        
        if contextModel.hasAvailableAssets {
            print("Loading assets...")
            try await contextModel.requestAssets()
            print("Assets requested 👍🏼")
        }
        try contextModel.load()
        
        try timerTrack("Calculating vectors the naive way") {
            for chunk in chunks {
                let result = try contextModel.embeddingResult(for: chunk.content, language: nil)
                _ = try result.meanVectorNaive()
            }
        }
        timerReport("Calculating vectors the naive way")
    }

}


#Playground("Calc Distances Naive")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    
    print("Calculating distance between \(chunks.count) pairs of sentences with naive distance implementation")
    
    if let contextModel = NLContextualEmbedding(language: .english)
    {
        let status = """
        Created Contextual Embedding 👍🏼.
          Dimension: \(contextModel.dimension),
          Description: \(contextModel.description),
          Model Identifier: \(contextModel.modelIdentifier)
        """
        print (status)
        
        if contextModel.hasAvailableAssets {
            print("Loading assets...")
            try await contextModel.requestAssets()
            print("Assets requested 👍🏼")
        }
        try contextModel.load()
        
        try timerTrack("Calculating distances the naive way") {
            
                for chunk in chunks {
                    _ = try contextModel.distanceNaive(between: chunk.content, and: chunks.randomElement()!.content)
                }
        }
        timerReport("Calculating distances the naive way")
    }
}

#Playground("Calc closest in array naive")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    print("Calculating the closest chunks in an array of \(chunks.count) chunks with naive implementations")

    func findClosest<T: Embeddable>(to question: String, in chunks: [T], k: Int = 3) throws -> [T] {
        guard let contextModel = NLContextualEmbedding(language: .english) else {
            // Fallback if embedding is unavailable
            return Array(chunks.prefix(k))
        }
        var distanceCalculations = 0
        let sorted = try chunks.sorted { lhs, rhs in
            let dl = try contextModel.distanceNaive(between: question, and: lhs.content)
            let dr = try contextModel.distanceNaive(between: question, and: rhs.content)
            distanceCalculations += 2
            return dl < dr
        }
        print("\(distanceCalculations) naive distance calculations done.")
        return Array(sorted.prefix(k))
    }

    try timerTrack("Calculating the closest chunks in an array of chunks") {
        let closeOnes = try findClosest(to: "What is the capital of France?", in: chunks)
    }
    timerReport("Calculating the closest chunks in an array of chunks")
}

