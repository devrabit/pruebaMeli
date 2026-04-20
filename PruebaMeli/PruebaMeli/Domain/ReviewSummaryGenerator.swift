//
//  ReviewSummaryGenerator.swift
//  PruebaMeli
//

import Foundation

protocol ReviewSummaryGenerator {
    func generateSummary(from reviews: [Review]) async throws -> ReviewSummary
}
