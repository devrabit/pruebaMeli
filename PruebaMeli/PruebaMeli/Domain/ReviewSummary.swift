//
//  ReviewSummary.swift
//  PruebaMeli
//

import Foundation

struct ReviewSummary: Codable, Equatable {
    let sentiment: Sentiment
    let strengths: [String]
    let weaknesses: [String]
    let summary: String
}

enum Sentiment: String, Codable, Equatable {
    case positive
    case neutral
    case negative
}
