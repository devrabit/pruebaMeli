//
//  GetProductsUseCaseTests.swift
//  PruebaMeliTests
//

import Combine
import XCTest

@testable import PruebaMeli

final class GetProductsUseCaseTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testExecutePropagatesRepositorySuccess() {
        let expected = [
            Product(id: 1, title: "A", image: "https://example.com/a.jpg", reviews: [
                Review(author: "u", rating: 5, text: "ok")
            ])
        ]
        let repo = MockProductRepository(result: .success(expected))
        let sut = GetProductsUseCase(repository: repo)

        let exp = expectation(description: "receive products")
        sut.execute()
            .sink { completion in
                if case .failure(let e) = completion {
                    XCTFail("Unexpected failure: \(e)")
                }
            } receiveValue: { products in
                XCTAssertEqual(products, expected)
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1)
    }

    func testExecutePropagatesRepositoryFailure() {
        let repo = MockProductRepository(result: .failure(URLError(.notConnectedToInternet)))
        let sut = GetProductsUseCase(repository: repo)

        let exp = expectation(description: "failure")
        sut.execute()
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure")
                case .failure(let error as URLError):
                    XCTAssertEqual(error.code, .notConnectedToInternet)
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                }
            } receiveValue: { _ in
                XCTFail("Expected no value")
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1)
    }
}

private final class MockProductRepository: ProductRepository {
    let result: Result<[Product], Error>

    init(result: Result<[Product], Error>) {
        self.result = result
    }

    func fetchProducts() -> AnyPublisher<[Product], Error> {
        switch result {
        case .success(let products):
            return Just(products).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
