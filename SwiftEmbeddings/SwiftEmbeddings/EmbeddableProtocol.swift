//
//  HasContentProtocol.swift
//
//  Created by Till Gartner on 27.09.25.
//
import Foundation
import NaturalLanguage

enum EmbeddingError: Error, LocalizedError{
    case emptyContent
    case modelUnavailable
    case computationFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .emptyContent: return "No content to embed."
        case .modelUnavailable: return "Embedding model not available."
        case .computationFailed(let err): return err.localizedDescription
        }
    }
}

protocol Embeddable: Identifiable {
    var content: String { get }
}
