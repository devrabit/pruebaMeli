//
//  GetProductsUseCase.swift
//  PruebaMeli
//

import Combine
import Foundation

final class GetProductsUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[Product], Error> {
        repository.fetchProducts()
    }
}
