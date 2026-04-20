//
//  Product.swift
//  PruebaMeli
//

import Foundation

struct Product: Codable, Equatable {
    let id: Int
    let title: String
    let image: String
    let reviews: [Review]

    var reviewCount: Int {
        reviews.count
    }

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        let average = Double(total) / Double(reviews.count)
        return (average * 10).rounded() / 10
    }
}

struct Review: Codable, Equatable {
    let author: String
    let rating: Int
    let text: String
}

extension Product: Identifiable {}
