//
//  Chunk.swift
//
//  Created by Till Gartner on 27.09.25.
//

import CryptoKit
import Foundation

struct Chunk: Codable, Embeddable {
    let chunk_file: String
    let original_url: String
    let title: String
    let content: String

    var id: String {
        let digest = SHA256.hash(data: Data(content.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    var shortDescription: String {
        "'\(content.prefix(20))...'"
    }
    
    static let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    static let chunks_all:[Chunk] = Bundle.main.decode("merged_chunks_all.json")

}
