import Combine
import XCTest

@testable import PruebaMeli

final class PruebaMeliTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testViewModelInitialStateIsEmpty() {
        let repository = RepositorySpy(result: .success([]), cachedProducts: [])
        let sut = ProductViewModel(
            getProductsUseCase: GetProductsUseCase(repository: repository),
            loadCachedProductsUseCase: LoadCachedProductsUseCase(repository: repository)
        )

        XCTAssertTrue(sut.products.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }

    func testAverageRatingRoundsToOneDecimal() {
        let product = Product(
            id: 1,
            title: "Test",
            image: "",
            reviews: [
                Review(author: "A", rating: 5, text: ""),
                Review(author: "B", rating: 4, text: ""),
                Review(author: "C", rating: 4, text: ""),
            ]
        )

        XCTAssertEqual(product.averageRating, 4.3)
        XCTAssertEqual(product.reviewCount, 3)
    }

    func testAverageRatingIsZeroForEmptyReviews() {
        let product = Product(id: 1, title: "Test", image: "", reviews: [])

        XCTAssertEqual(product.averageRating, 0.0)
        XCTAssertEqual(product.reviewCount, 0)
    }

    func testLoadCachedProductsUseCaseReturnsPersistedProducts() {
        let cached = [Product(id: 7, title: "Cached", image: "", reviews: [])]
        let repository = RepositorySpy(result: .success([]), cachedProducts: cached)
        let sut = LoadCachedProductsUseCase(repository: repository)

        XCTAssertEqual(sut.execute(), cached)
    }

    func testViewModelLoadsCacheThenRefreshesFromAPI() {
        let cached = [Product(id: 1, title: "Local", image: "", reviews: [])]
        let remote = [Product(id: 2, title: "Remote", image: "", reviews: [Review(author: "U", rating: 5, text: "")])]
        let repository = RepositorySpy(
            result: .success(remote),
            cachedProducts: cached,
            fetchDelayMilliseconds: 150
        )
        let sut = ProductViewModel(
            getProductsUseCase: GetProductsUseCase(repository: repository),
            loadCachedProductsUseCase: LoadCachedProductsUseCase(repository: repository)
        )

        let exp = expectation(description: "remote products loaded")
        sut.$products
            .dropFirst()
            .sink { products in
                if products == remote {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.load()

        XCTAssertEqual(sut.products, cached)
        wait(for: [exp], timeout: 1)
    }

    func testViewModelSetsErrorWhenAPIFails() {
        let cached = [Product(id: 1, title: "Local", image: "", reviews: [])]
        let repository = RepositorySpy(result: .failure(URLError(.timedOut)), cachedProducts: cached)
        let sut = ProductViewModel(
            getProductsUseCase: GetProductsUseCase(repository: repository),
            loadCachedProductsUseCase: LoadCachedProductsUseCase(repository: repository)
        )

        sut.load()

        XCTAssertEqual(sut.products, cached)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }

    func testPerformanceRenderingDataFor100PlusProducts() {
        let products = (1...120).map { index in
            Product(
                id: index,
                title: "Producto \(index)",
                image: "https://example.com/\(index).jpg",
                reviews: (0..<(index % 20)).map { reviewIndex in
                    Review(author: "A\(reviewIndex)", rating: (reviewIndex % 5) + 1, text: "ok")
                }
            )
        }

        measure {
            _ = products.map { product in
                (product.title, product.averageRating, product.reviewCount)
            }
        }
    }
}

private final class RepositorySpy: ProductRepository {
    private let result: Result<[Product], Error>
    private(set) var cachedProducts: [Product]
    private let fetchDelayMilliseconds: Int

    init(result: Result<[Product], Error>, cachedProducts: [Product], fetchDelayMilliseconds: Int = 0) {
        self.result = result
        self.cachedProducts = cachedProducts
        self.fetchDelayMilliseconds = fetchDelayMilliseconds
    }

    func fetchProducts() -> AnyPublisher<[Product], Error> {
        switch result {
        case .success(let products):
            return Just(products)
                .delay(for: .milliseconds(fetchDelayMilliseconds), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func saveProducts(_ products: [Product]) {
        cachedProducts = products
    }

    func loadLocalProducts() -> [Product] {
        cachedProducts
    }
}
