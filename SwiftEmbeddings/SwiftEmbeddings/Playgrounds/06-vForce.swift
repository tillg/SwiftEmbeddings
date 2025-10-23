//
//  06-vForce.swift
//
//  Created by Till Gartner on 20.10.25.
//

import Accelerate
import Foundation
import Playgrounds

#Playground {
    let n = 10_000
    
    
    let x = (0..<n).map { _ in
        Double.random(in: 1 ... 10_000)
    }
    
    timerTrack("map") {
        let y = x.map {
            return sqrt($0)
        }
    }
    
    timerTrack("vForce") {
        let y = [Double](unsafeUninitializedCapacity: n) { buffer, initializedCount in
            vForce.sqrt(x,
                        result: &buffer)
            
            initializedCount = n
        }
    }
    
    timerReport("map")
    timerReport("vForce")
    
}
