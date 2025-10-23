//
//  VectorsMean.swift
//
//  Created by Till Gartner on 28.09.25.
//

import Accelerate
import NaturalLanguage
import Foundation

func mean(of vectors: [[Double]]) -> [Double]? {
    guard let first = vectors.first else { return nil }
    let length = first.count
    var result = Array(repeating: 0.0, count: length)
    
    for v in vectors {
        precondition(v.count == length, "All vectors must have the same length")
        for i in 0..<length {
            result[i] += v[i]
        }
    }
    
    let count = Double(vectors.count)
    for i in 0..<length {
        result[i] /= count
    }
    
    return result
}

func meanTokenVector(in range: Range<String.Index>,
                     using enumerator: (Range<String.Index>, @escaping ([Double], Range<String.Index>) -> Bool) -> Void) -> [Double]? {
    var result: [Double]? = nil
    var count = 0
    
    enumerator(range) { vector, _ in
        if result == nil {
            result = Array(repeating: 0.0, count: vector.count)
        } else {
            precondition(result!.count == vector.count, "All vectors must have the same length")
        }
        
        for i in 0..<vector.count {
            result![i] += vector[i]
        }
        
        count += 1
        return true // continue enumeration
    }
    
    guard var sum = result, count > 0 else { return nil }
    
    let divisor = Double(count)
    for i in 0..<sum.count {
        sum[i] /= divisor
    }
    
    return sum
}

/// Mean vector of equally-sized [Double] vectors using vDSP
func mean2(of vectors: [[Double]]) -> [Double]? {
    guard let first = vectors.first else { return nil }
    let n = first.count
    let m = vectors.count
    precondition(vectors.allSatisfy { $0.count == n }, "All vectors must have same length")
    
    // Start with the first vector to avoid an extra allocation/zero fill
    var acc = first
    
    // Accumulate the rest, in-place (vDSP is SIMD-accelerated)
    for i in 1..<m {
        vDSP.add(acc, vectors[i], result: &acc)
    }
    
    // Scale by 1/m to get the mean
    let invM = 1.0 / Double(m)
    vDSP.multiply(invM, acc, result: &acc)
    return acc
}

func cosineSimilarityNaive(_ a: [Double], _ b: [Double]) -> Double? {
    guard a.count == b.count, !a.isEmpty, !b.isEmpty else {
        return nil // vectors must have same size and not be empty
    }
    var dotproduct = 0.0
    var firstSquared = 0.0
    var secondSquared = 0.0
    for i in 0..<a.count {
        dotproduct += a[i] * b[i]
        firstSquared += a[i] * a[i]
        secondSquared += b[i] * b[i]
    }
    let normA = sqrt(firstSquared)
    let normB = sqrt(secondSquared)
    
    guard normA > 0 && normB > 0 else {
        return nil
    }
    return dotproduct / (normA * normB)
}


func cosineSimilarityZip(_ a: [Double], _ b: [Double]) -> Double? {
    guard a.count == b.count, !a.isEmpty else {
        return nil // vectors must have same size and not be empty
    }
    
    let dotProduct = zip(a, b).map(*).reduce(0, +)
    let normA = sqrt(a.map { $0 * $0 }.reduce(0, +))
    let normB = sqrt(b.map { $0 * $0 }.reduce(0, +))
    
    guard normA > 0 && normB > 0 else {
        return nil // avoid division by zero
    }
    
    return dotProduct / (normA * normB)
}


func cosineSimilarity2(_ a: [Double], _ b: [Double]) -> Double? {
    guard a.count == b.count, !a.isEmpty else {
        return nil
    }
    
    var dot: Double = 0.0
    vDSP_dotprD(a, 1, b, 1, &dot, vDSP_Length(a.count))
    
    var normA: Double = 0.0
    var normB: Double = 0.0
    vDSP_svesqD(a, 1, &normA, vDSP_Length(a.count))
    vDSP_svesqD(b, 1, &normB, vDSP_Length(b.count))
    
    normA = sqrt(normA)
    normB = sqrt(normB)
    
    guard normA > 0 && normB > 0 else {
        return nil
    }
    
    return dot / (normA * normB)
}
