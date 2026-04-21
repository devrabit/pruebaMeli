//
//  SummaryRepository.swift
//  PruebaMeli
//

import Foundation

protocol SummaryRepository {
    func saveSummary(_ summary: ReviewSummary, for productId: Int)
    func loadSummary(for productId: Int) -> ReviewSummary?
    /// Todos los resúmenes persistidos (p. ej. para hidratar UI al reabrir la app).
    func loadAllSummaries() -> [Int: ReviewSummary]
}
