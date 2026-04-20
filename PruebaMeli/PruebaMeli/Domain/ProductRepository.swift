//
//  ProductRepository.swift
//  PruebaMeli
//

import Combine
import Foundation

protocol ProductRepository {
    func fetchProducts() -> AnyPublisher<[Product], Error>
}
