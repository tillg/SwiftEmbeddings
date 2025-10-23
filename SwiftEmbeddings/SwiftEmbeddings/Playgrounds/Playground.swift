//
//  Playground.swift
//
//  Created by Till Gartner on 26.09.25.
//

import FoundationModels
import NaturalLanguage
import Playgrounds

//
//
//#Playground {
//
//    let question = """
//        How can I extend a protocol?
//    """
//    var chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
//
//    if let contextModel = NLContextualEmbedding(language: .english)
//    {
//        let status = """
//        Created Contextual Embedding 👍🏼.
//          Dimension: \(contextModel.dimension),
//          Description: \(contextModel.description),
//          Model Identifier: \(contextModel.modelIdentifier)
//        """
//        print (status)
//        
//        if contextModel.hasAvailableAssets {
//            print("Loading assets...")
//            try await contextModel.requestAssets()
//            print("Assets loaded 👍🏼")
//        }
//        try contextModel.load()
//        
//        print("contextModel: Calc Mean - Started...")
//        _ = try time("contextModel: Calc Mean") {
//            for i in chunks.indices {
//                let vector = try contextModel.vector(for: chunks[i].content, language: .english)
//                chunks[i].vector = vector
//            }
//        }
//        print("contextModel: Calc distance with mean & cosine sim - Started...")
//        _ = try time("contextModel: Calc distance with mean & cosine sim") {
//            for chunk in chunks {
//                let distance = try contextModel.distance(between: question, and: chunk.content)
//            }
//        }
//
//    } else {
//        print("Error: Failed to create NLContextualEmbedding for English.")
//    }
//    
//    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
//        let status = """
//        Created NLEmbedding 👍🏼.
//          Dimension: \(sentenceEmbedding.dimension)
//        """
//        print (status)
//        
//        print("sentenceEmbedding: Calc Vactor - Started...")
//        _ = try time("sentenceEmbedding: Calc Vactor") {
//            for i in chunks.indices {
//                let vector = try sentenceEmbedding.vector(for: chunks[i].content)
//                chunks[i].vector = vector
//            }
//        }
//        print("sentenceEmbedding: Calc distance - Started...")
//        _ = try time("sentenceEmbedding: Calc distance") {
//            for chunk in chunks {
//                let distance = try sentenceEmbedding.distance(between: question, and: chunk.content)
//            }
//        }
//
//
//    }
//
//}


#Playground {
    if let embeddingModel = NLContextualEmbedding(language: .english)
    {
        let status = """
        Created Sentence Embedding 👍🏼.
          Dimension: \(embeddingModel.dimension),
          Description: \(embeddingModel.description),
          Languages: \(embeddingModel.languages)
        """
        print (status)
        if embeddingModel.hasAvailableAssets {
            print("Loading assets...")
            try await embeddingModel.requestAssets()
            print("Assets loaded 👍🏼")
        }
        try embeddingModel.load()
        let sentence = "This is a sentence."
        let result = try embeddingModel.embeddingResult(for: sentence, language: .english)
        let resultDesc = "NLEmbeddingResult: language: \(result.language), sequenceLength: \(result.sequenceLength), string: \(result.string)"
        print (resultDesc)
        
        // Inspect tokens + their vectors
        result.enumerateTokenVectors(in: result.string.startIndex..<result.string.endIndex) { vector, range in
            let token = result.string[range]
            print("Vector for token [\(token)]")
            
            // Return true to keep enumerating, false to stop early
            return true
        }
        
        if let meanVector = meanTokenVector(in: result.string.startIndex..<result.string.endIndex, using: result.enumerateTokenVectors) {
            print(meanVector)
        }

    } else {
        print("Error: Failed to create NLContextualEmbedding for English.")
    }
}

//
//#Playground {
//    let question = """
//        How do I define a protocol?
//        """
//    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
//    print("No of chunks: \(chunks.count)")
//    let proxFinder = try ProximityFinder()
//    let bestAnswers = proxFinder.findClosest(to: question, in: chunks)
//    print(bestAnswers.count)
//    print("\(bestAnswers)")
//}

//#Playground {
//    let sentence = "This is a sentence."
//    let sentences = ["This is a sentence.", "This is another sentence."]
//    let proxFinder = try ProximityFinder()
//    let closests = proxFinder.findClosest(to: sentence, in: sentences)
//    print(closests)
//
//}


//
//#Playground {
//    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
//        let sentence = "This is a sentence."
//        
//        if let vector = sentenceEmbedding.vector(for: sentence) {
//            print(vector)
//        }
//        
//        let dist = sentenceEmbedding.distance(between: sentence, and: "That is a sentence.")
//        print(dist)
//    } else {
//        print("No SentenceEmbedding")
//    }
//}
//
//

//

//
//
//
//#Playground {
//    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
//        let sentence = "This is a sentence."
//        if let vector = sentenceEmbedding.vector(for: sentence) {
//            print(vector)
//        }
//        let distance = sentenceEmbedding.distance(between: sentence, and: "That is a sentence.")
//        print(distance.description)
//    } else {
//        print("No sentenceEmbedding!")
//    }
//}
//

