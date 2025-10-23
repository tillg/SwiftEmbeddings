//
//  PlayGroundVectors.swift
//
//  Created by Till Gartner on 28.09.25.
//

import Foundation
import NaturalLanguage
import Playgrounds

#Playground
{
    // Mock enumerateTokenVectors for testing
    func mockEnumerateTokenVectors(in range: Range<String.Index>,
                                   using block: ([Double], Range<String.Index>) -> Bool) {
        let vectors = [
            [1.0, 2.0, 3.0],
            [4.0, 5.0, 6.0],
            [7.0, 8.0, 9.0]
        ]
        
        for v in vectors {
            let shouldContinue = block(v, range)
            if !shouldContinue { break }
        }
    }

    // Dummy string & range (not used in mock)
    let testString = "dummy"
    let testRange = testString.startIndex..<testString.endIndex

    if let meanVector = meanTokenVector(in: testRange, using: mockEnumerateTokenVectors) {
        print(meanVector)  // [4.0, 5.0, 6.0]
    }
}

#Playground
{

    let vectors = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0]
    ]

    if let meanVector = mean(of: vectors) {
        print(meanVector)  // [4.0, 5.0, 6.0]
    }
    if let meanVector2 = mean2(of: vectors) {
        print(meanVector2)  // [4.0, 5.0, 6.0]
    }
}
