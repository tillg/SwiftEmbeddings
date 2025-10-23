//
//  EmbeddingExtension.swift
//
//  Created by Till Gartner on 28.09.25.
//

import Accelerate
import Foundation
import NaturalLanguage

extension NLContextualEmbedding {
    
    func vectorNaive(for sentence: String, language: NLLanguage?) throws -> [Double] {

        // Time the embedding computation; the closure RETURNS the value
        let result = try timerTrack("Embedding") {
            try embeddingResult(for: sentence, language: language)
        }

        // Time the mean computation; again, return from the closure
        let meanVector: [Double]? = timerTrack("MeanVector") {
            result.meanVectorNaive()
        }

        // Unwrap and return
        if let mean = meanVector {
            return mean
        } else {
            print("Error! No mean vector found!")
            return []
        }
    }
    
    func vectorDSP(for sentence: String, language: NLLanguage?) throws -> [Double] {

        // Time the embedding computation; the closure RETURNS the value
        let result = try timerTrack("Embedding") {
            try embeddingResult(for: sentence, language: language)
        }
        let meanVector: [Double]? = timerTrack("MeanVector") {
            result.meanVectorDSP()
        }

        // Unwrap and return
        if let mean = meanVector {
            return mean
        } else {
            print("Error! No mean vector found!")
            return []
        }
    }
    
    func distanceNaive(between firstString: String, and secondString: String) throws -> Double {
        let firstVector =  try self.vectorNaive(for: firstString, language: nil)
        let secondVector = try self.vectorNaive(for: secondString, language: nil)
        
        let cosineSim = cosineSimilarityNaive(firstVector, secondVector) ?? 0.0
        let distance = 1 - cosineSim
        return distance
    }
}

extension NLContextualEmbeddingResult {
    
    func meanVectorNaive() -> [Double]? {
        var sumVector: [Double]? = nil
        var count = 0
        self.enumerateTokenVectors(in: self.string.startIndex..<self.string.endIndex) { vector, _ in
            if sumVector == nil {
                sumVector = vector
            } else {
                precondition(sumVector!.count == vector.count, "All vectors must have the same length")
                for i in 0..<sumVector!.count {
                    sumVector![i] += vector[i]
                }
            }
            count += 1
            return true
        }
        
        // Check that we are not facing an empty arry of vectors - avoid div by 0
        guard var sumVector = sumVector, count > 0 else {
            print("getMeanVectorNaive: No token vectors to average")
            return nil
        }
        
        let divisor = Double(count)
        for i in 0..<sumVector.count {
            sumVector[i] /= divisor
        }
        return sumVector
    }
    
    func meanVectorDSP() -> [Double]? {
        var sumVector: [Double]? = nil
        var count = 0
        self.enumerateTokenVectors(in: self.string.startIndex..<self.string.endIndex) { vector, _ in
            if sumVector == nil {
                sumVector = vector
            } else {
                precondition(sumVector!.count == vector.count, "All vectors must have the same length")
                sumVector = vDSP.add(sumVector!, vector)
            }
            count += 1
            return true
        }
        
        // Check that we are not facing an empty arry of vectors - avoid div by 0
        guard var sumVector = sumVector, count > 0 else {
            print("getMeanVectorNaive: No token vectors to average")
            return nil
        }
        
        let divisor = Double(count)
        sumVector = vDSP.multiply(divisor, sumVector)
        return sumVector
    }
}
