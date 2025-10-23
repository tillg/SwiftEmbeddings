
//
//  NLEmbedding.swift
//
//  Created by Till Gartner on 01.10.25.
//

import NaturalLanguage
import Playgrounds



#Playground("Calc closest in array naive & cache")
{
    let chunks: [Chunk] = Chunk.chunks_all

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
    let desc = "Loading \(chunks.count) chunks in embeddingStore ~ calculating vectors"
    print(desc)
    try await timerTrack(desc) {
        await embeddingStore.loadChunksNaive(chunks)
    }
    timerReport(desc)
    timerReport("Embedding")
    timerReport("MeanVector")

    print("Done loading chunks and computing vectors")
    await timerTrack("Calculating closest 5") {
        _ = await embeddingStore.closest(to: "How do I build an iOS App?", k: 5)
    }
    timerReport("Calculating closest 5")
}
