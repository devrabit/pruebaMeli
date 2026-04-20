//
//  Product.swift
//  PruebaMeli
//

import Foundation

struct Product: Equatable {
    let id: Int
    let title: String
    let image: String
    let reviews: [Review]
}

struct Review: Equatable {
    let author: String
    let rating: Int
    let text: String
}

extension Product: Identifiable {}
