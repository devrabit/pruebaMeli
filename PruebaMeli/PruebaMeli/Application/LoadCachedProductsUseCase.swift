//
//  LoadCachedProductsUseCase.swift
//  PruebaMeli
//

import Foundation

final class LoadCachedProductsUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute() -> [Product] {
        repository.loadLocalProducts()
    }
}
