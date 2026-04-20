//
//  SummaryRepository.swift
//  PruebaMeli
//

import Foundation

protocol SummaryRepository {
    func saveSummary(_ summary: ReviewSummary, for productId: Int)
    func loadSummary(for productId: Int) -> ReviewSummary?
}
