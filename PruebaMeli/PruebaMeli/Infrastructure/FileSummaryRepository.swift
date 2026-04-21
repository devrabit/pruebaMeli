//
//  FileSummaryRepository.swift
//  PruebaMeli
//

import Foundation

final class FileSummaryRepository: SummaryRepository {
    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(fileManager: FileManager = .default) {
        let baseDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        fileURL = baseDirectory.appendingPathComponent("review-summaries.json")
    }

    func saveSummary(_ summary: ReviewSummary, for productId: Int) {
        var store = loadStore()
        store[String(productId)] = summary
        guard let data = try? encoder.encode(store) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func loadSummary(for productId: Int) -> ReviewSummary? {
        let store = loadStore()
        return store[String(productId)]
    }

    func loadAllSummaries() -> [Int: ReviewSummary] {
        var result: [Int: ReviewSummary] = [:]
        for (key, summary) in loadStore() {
            guard let id = Int(key) else { continue }
            result[id] = summary
        }
        return result
    }

    private func loadStore() -> [String: ReviewSummary] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return [:]
        }
        return (try? decoder.decode([String: ReviewSummary].self, from: data)) ?? [:]
    }
}
