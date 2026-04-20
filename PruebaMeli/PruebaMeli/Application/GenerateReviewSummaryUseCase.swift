//
//  GenerateReviewSummaryUseCase.swift
//  PruebaMeli
//

import Foundation

final class GenerateReviewSummaryUseCase {
    private let generator: ReviewSummaryGenerator
    private let repository: SummaryRepository

    init(generator: ReviewSummaryGenerator, repository: SummaryRepository) {
        self.generator = generator
        self.repository = repository
    }

    func execute(product: Product) async throws -> ReviewSummary {
        if let cached = repository.loadSummary(for: product.id) {
            return cached
        }

        let summary = try await generator.generateSummary(from: product.reviews)
        repository.saveSummary(summary, for: product.id)
        return summary
    }
}
