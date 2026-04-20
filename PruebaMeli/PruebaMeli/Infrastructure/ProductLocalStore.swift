//
//  ProductLocalStore.swift
//  PruebaMeli
//

import Foundation

protocol ProductLocalStore {
    func save(_ products: [Product])
    func load() -> [Product]
}

final class FileProductLocalStore: ProductLocalStore {
    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(fileManager: FileManager = .default) {
        let baseDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = baseDirectory.appendingPathComponent("products-cache.json")
    }

    func save(_ products: [Product]) {
        do {
            let data = try encoder.encode(products)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Best-effort local cache: ignore persistence failures silently.
        }
    }

    func load() -> [Product] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        return (try? decoder.decode([Product].self, from: data)) ?? []
    }
}
