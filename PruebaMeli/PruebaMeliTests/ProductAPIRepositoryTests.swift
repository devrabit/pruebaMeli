import Combine
import XCTest

@testable import PruebaMeli

final class ProductAPIRepositoryTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testFetchProductsSavesProductsLocally() {
        let payload = """
        [
          {
            "id": 10,
            "title": "Mock",
            "image": "https://example.com/a.jpg",
            "reviews": [
              { "author": "Ana", "rating": 5, "text": "Excelente" }
            ]
          }
        ]
        """.data(using: .utf8)!
        let network = NetworkClientStub(result: .success(payload))
        let localStore = LocalStoreSpy()
        let sut = ProductAPIRepository(network: network, localStore: localStore)

        let exp = expectation(description: "products loaded")
        sut.fetchProducts()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { products in
                XCTAssertEqual(products.count, 1)
                XCTAssertEqual(localStore.savedProducts, products)
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1)
    }

    func testLoadLocalProductsReturnsCachedProducts() {
        let network = NetworkClientStub(result: .failure(URLError(.badURL)))
        let localStore = LocalStoreSpy()
        localStore.cachedProducts = [Product(id: 1, title: "Cached", image: "", reviews: [])]
        let sut = ProductAPIRepository(network: network, localStore: localStore)

        XCTAssertEqual(sut.loadLocalProducts(), localStore.cachedProducts)
    }
}

private final class NetworkClientStub: NetworkClient {
    let result: Result<Data, Error>

    init(result: Result<Data, Error>) {
        self.result = result
    }

    func request<T: Decodable>(_ endpoint: String) -> AnyPublisher<T, Error> {
        switch result {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return Just(decoded).setFailureType(to: Error.self).eraseToAnyPublisher()
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

private final class LocalStoreSpy: ProductLocalStore {
    private(set) var savedProducts: [Product] = []
    var cachedProducts: [Product] = []

    func save(_ products: [Product]) {
        savedProducts = products
        cachedProducts = products
    }

    func load() -> [Product] {
        cachedProducts
    }
}
