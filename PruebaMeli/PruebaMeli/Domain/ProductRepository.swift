//
//  ProductRepository.swift
//  PruebaMeli
//

import Combine
import Foundation

protocol ProductRepository {
    func fetchProducts() -> AnyPublisher<[Product], Error>
    func saveProducts(_ products: [Product])
    func loadLocalProducts() -> [Product]
}
