//
//  NLEmbedding.swift
//
//  Created by Till Gartner on 01.10.25.
//

import NaturalLanguage
import Playgrounds




#Playground("Calc Distances Naive w/ cache")
{
    var chunks:[Chunk] = Chunk.chunks
    
    print(
        "Calculating distance between \(chunks.count) pairs of sentences with naive distance and cached vectors"
    )
    
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
        
        let embeddingStore = EmbeddingStore(model: contextModel)
        try await timerTrack(
            "Calculating distances the naive imple & cached vectors"
        ) {
            await embeddingStore.loadChunksNaive(chunks)
            await embeddingStore.closest(to: "Hello world")
        }
        timerReport("Calculating distances the naive imple & cached vectors")
    }
}

#Playground("Calc closest in array naive & cache")
{
    let chunks: [Chunk] = Chunk.chunks

    guard let contextModel = NLContextualEmbedding(language: .english) else {
        fatalError("Cannot create NLContextualEmbedding")
    }

    if contextModel.hasAvailableAssets {
        print("Loading assets...")
        try await contextModel.requestAssets()
        print("Assets requested 👍🏼")
    }

    try contextModel.load()

    let embeddingStore = EmbeddingStore(model: contextModel)

    try await timerTrack("Loading chunks in embeddingStore ~ calculating vectors") {
        await embeddingStore.loadChunksNaive(chunks)
        // Optionally perform a simple query to ensure vectors are computed
        _ = await embeddingStore.closest(to: "Hello world")
    }
    timerReport("Loading chunks in embeddingStore ~ calculating vectors")

    await timerTrack("Calculating closest 5") {
        _ = await embeddingStore.closest(to: "How do I build an iOS App?", k: 5)
    }
    timerReport("Calculating closest 5")
}
