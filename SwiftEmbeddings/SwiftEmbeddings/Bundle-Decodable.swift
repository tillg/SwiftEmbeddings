//
//  Bundle-Decodable.swift
//
//  Created by Till Gartner on 03.09.25.
//

import Foundation

extension Bundle {
    func decode(_ file: String) -> [Chunk] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        func keyPath(from codingPath: [CodingKey], appending key: CodingKey? = nil) -> String {
            let fullPath: [CodingKey]
            if let key = key { fullPath = codingPath + [key] } else { fullPath = codingPath }
            if fullPath.isEmpty { return "<root>" }
            var path = ""
            for k in fullPath {
                if let i = k.intValue {
                    path += "[\(i)]"
                } else {
                    if !path.isEmpty { path += "." }
                    path += k.stringValue
                }
            }
            return path
        }

        do {
            return try decoder.decode([Chunk].self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            let path = keyPath(from: context.codingPath, appending: key)
            let errorStr = "Failed to decode \(file) from bundle due to missing key at path \(path) – \(context.debugDescription)"
            fatalError(errorStr)
        } catch DecodingError.typeMismatch(let type, let context) {
            let path = keyPath(from: context.codingPath)
            let errorStr = "Failed to decode \(file) from bundle due to type mismatch for \(type) at path \(path) – \(context.debugDescription)"
            fatalError(errorStr)
        } catch DecodingError.valueNotFound(let type, let context) {
            let path = keyPath(from: context.codingPath)
            let errorStr = "Failed to decode \(file) from bundle due to missing \(type) value at path \(path) – \(context.debugDescription)"
            fatalError(errorStr)
        } catch DecodingError.dataCorrupted(let context) {
            let path = keyPath(from: context.codingPath)
            let errorStr = "Failed to decode \(file) from bundle because the JSON is invalid at path \(path) – \(context.debugDescription)"
            fatalError(errorStr)
        } catch {
            let errorStr = "Failed to decode \(file) from bundle: \(error.localizedDescription)"
            fatalError(errorStr)
        }
    }
}
