//
//  RegenerateReviewSummaryUseCase.swift
//  PruebaMeli
//

import Foundation

final class RegenerateReviewSummaryUseCase {
    private let generator: ReviewSummaryGenerator
    private let repository: SummaryRepository

    init(generator: ReviewSummaryGenerator, repository: SummaryRepository) {
        self.generator = generator
        self.repository = repository
    }

    func execute(product: Product) async throws -> ReviewSummary {
        let summary = try await generator.generateSummary(from: product.reviews)
        repository.saveSummary(summary, for: product.id)
        return summary
    }
}
