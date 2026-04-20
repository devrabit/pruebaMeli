//
//  ProductAPIRepository.swift
//  PruebaMeli
//

import Combine
import Foundation

private struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let image: String
    let reviews: [ReviewDTO]
}

private struct ReviewDTO: Decodable {
    let author: String
    let rating: Int
    let text: String
}

private extension ProductDTO {
    func toDomain() -> Product {
        Product(
            id: id,
            title: title,
            image: image,
            reviews: reviews.map { Review(author: $0.author, rating: $0.rating, text: $0.text) }
        )
    }
}

final class ProductAPIRepository: ProductRepository {
    private let network: NetworkClient
    private let localStore: ProductLocalStore

    init(network: NetworkClient, localStore: ProductLocalStore) {
        self.network = network
        self.localStore = localStore
    }

    func fetchProducts() -> AnyPublisher<[Product], Error> {
        network.request("/products")
            .map { (dtos: [ProductDTO]) in dtos.map { $0.toDomain() } }
            .handleEvents(receiveOutput: { [weak self] products in
                self?.saveProducts(products)
            })
            .eraseToAnyPublisher()
    }

    func saveProducts(_ products: [Product]) {
        localStore.save(products)
    }

    func loadLocalProducts() -> [Product] {
        localStore.load()
    }
}
