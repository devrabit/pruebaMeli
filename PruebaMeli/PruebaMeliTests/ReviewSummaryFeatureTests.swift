import Combine
import XCTest

@testable import PruebaMeli

final class ReviewSummaryFeatureTests: XCTestCase {
    func testGenerateUseCaseReturnsCachedSummaryWhenExists() async throws {
        let summary = ReviewSummary(
            sentiment: .positive,
            strengths: ["calidad"],
            weaknesses: ["precio"],
            summary: "Resumen cacheado"
        )
        let repository = SummaryRepositoryMock(stored: [1: summary])
        let generator = SummaryGeneratorMock()
        let useCase = GenerateReviewSummaryUseCase(generator: generator, repository: repository)

        let result = try await useCase.execute(product: makeProduct(id: 1, reviewCount: 8))

        XCTAssertEqual(result, summary)
        XCTAssertEqual(generator.calls, 0)
    }

    func testGenerateUseCaseGeneratesAndSavesWhenNoCache() async throws {
        let repository = SummaryRepositoryMock()
        let generator = SummaryGeneratorMock()
        generator.stub = ReviewSummary(
            sentiment: .neutral,
            strengths: ["envio"],
            weaknesses: ["empaque"],
            summary: "Resumen generado"
        )
        let useCase = GenerateReviewSummaryUseCase(generator: generator, repository: repository)

        let result = try await useCase.execute(product: makeProduct(id: 2, reviewCount: 8))

        XCTAssertEqual(result.summary, "Resumen generado")
        XCTAssertEqual(repository.loadSummary(for: 2)?.summary, "Resumen generado")
        XCTAssertEqual(generator.calls, 1)
    }

    func testRegenerateUseCaseOverwritesStoredSummary() async throws {
        let repository = SummaryRepositoryMock(stored: [
            3: ReviewSummary(sentiment: .negative, strengths: [], weaknesses: ["demora"], summary: "Viejo"),
        ])
        let generator = SummaryGeneratorMock()
        generator.stub = ReviewSummary(sentiment: .positive, strengths: ["calidad"], weaknesses: [], summary: "Nuevo")
        let useCase = RegenerateReviewSummaryUseCase(generator: generator, repository: repository)

        _ = try await useCase.execute(product: makeProduct(id: 3, reviewCount: 9))

        XCTAssertEqual(repository.loadSummary(for: 3)?.summary, "Nuevo")
    }

    func testOnDeviceGeneratorReturnsValidStructuredSummary() async throws {
        let generator = OnDeviceSummaryGenerator()
        let result = try await generator.generateSummary(from: makeReviews(count: 8))

        XCTAssertFalse(result.strengths.isEmpty)
        XCTAssertFalse(result.weaknesses.isEmpty)
        XCTAssertFalse(result.summary.isEmpty)
    }

    func testOnDeviceGeneratorThrowsWhenReviewsAreInsufficient() async {
        let generator = OnDeviceSummaryGenerator()
        do {
            _ = try await generator.generateSummary(from: makeReviews(count: 3))
            XCTFail("Expected insufficient reviews error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testSummaryRepositorySavesAndLoadsByProductId() {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("summary-repo-\(UUID().uuidString).json")
        let repository = FileSummaryRepositoryForTests(fileURL: path)
        let expected = ReviewSummary(
            sentiment: .positive,
            strengths: ["pantalla"],
            weaknesses: ["bateria"],
            summary: "Buen equipo"
        )

        repository.saveSummary(expected, for: 99)
        let loaded = repository.loadSummary(for: 99)

        XCTAssertEqual(loaded, expected)
    }

    func testViewModelHandlesLoadingStateAndSuccess() async throws {
        let product = makeProduct(id: 20, reviewCount: 8)
        let repository = SummaryRepositoryMock()
        let generator = SummaryGeneratorMock()
        generator.stub = ReviewSummary(sentiment: .positive, strengths: ["calidad"], weaknesses: [], summary: "ok")
        let viewModel = makeViewModel(generator: generator, summaryRepository: repository)

        viewModel.generateSummary(for: product)
        XCTAssertTrue(viewModel.loadingSummaryIds.contains(product.id))

        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertFalse(viewModel.loadingSummaryIds.contains(product.id))
        XCTAssertEqual(viewModel.summaries[product.id]?.summary, "ok")
        XCTAssertNil(viewModel.summaryErrors[product.id])
    }

    func testViewModelHandlesSummaryError() async throws {
        let product = makeProduct(id: 21, reviewCount: 8)
        let repository = SummaryRepositoryMock()
        let generator = SummaryGeneratorMock()
        generator.error = URLError(.cannotDecodeRawData)
        let viewModel = makeViewModel(generator: generator, summaryRepository: repository)

        viewModel.generateSummary(for: product)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(viewModel.loadingSummaryIds.contains(product.id))
        XCTAssertNotNil(viewModel.summaryErrors[product.id])
    }

    func testSummaryPerformanceForHundredProducts() {
        let generator = OnDeviceSummaryGenerator()
        let payload = makeReviews(count: 20)

        measure {
            for _ in 0..<120 {
                _ = try? awaitResult { try await generator.generateSummary(from: payload) }
            }
        }
    }

    private func makeViewModel(
        generator: ReviewSummaryGenerator,
        summaryRepository: SummaryRepository
    ) -> ProductViewModel {
        let productsRepository = ProductRepositoryMock()
        return ProductViewModel(
            getProductsUseCase: GetProductsUseCase(repository: productsRepository),
            loadCachedProductsUseCase: LoadCachedProductsUseCase(repository: productsRepository),
            generateSummaryUseCase: GenerateReviewSummaryUseCase(generator: generator, repository: summaryRepository),
            regenerateSummaryUseCase: RegenerateReviewSummaryUseCase(generator: generator, repository: summaryRepository)
        )
    }

    private func makeProduct(id: Int, reviewCount: Int) -> Product {
        Product(
            id: id,
            title: "P\(id)",
            image: "https://example.com/\(id).jpg",
            reviews: makeReviews(count: reviewCount)
        )
    }

    private func makeReviews(count: Int) -> [Review] {
        (0..<count).map { index in
            Review(
                author: "A\(index)",
                rating: (index % 5) + 1,
                text: index % 2 == 0 ? "Excelente calidad y envio rapido" : "Algo caro pero bueno"
            )
        }
    }
}

private final class SummaryGeneratorMock: ReviewSummaryGenerator {
    var stub = ReviewSummary(sentiment: .neutral, strengths: ["A"], weaknesses: ["B"], summary: "S")
    var error: Error?
    var calls = 0

    func generateSummary(from reviews: [Review]) async throws -> ReviewSummary {
        calls += 1
        if let error {
            throw error
        }
        return stub
    }
}

private final class SummaryRepositoryMock: SummaryRepository {
    private var storage: [Int: ReviewSummary]

    init(stored: [Int: ReviewSummary] = [:]) {
        storage = stored
    }

    func saveSummary(_ summary: ReviewSummary, for productId: Int) {
        storage[productId] = summary
    }

    func loadSummary(for productId: Int) -> ReviewSummary? {
        storage[productId]
    }
}

private final class ProductRepositoryMock: ProductRepository {
    func fetchProducts() -> AnyPublisher<[Product], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func saveProducts(_ products: [Product]) {}

    func loadLocalProducts() -> [Product] { [] }
}

private final class FileSummaryRepositoryForTests: SummaryRepository {
    private let fileURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func saveSummary(_ summary: ReviewSummary, for productId: Int) {
        var store = loadStore()
        store[String(productId)] = summary
        let data = try? encoder.encode(store)
        try? data?.write(to: fileURL, options: .atomic)
    }

    func loadSummary(for productId: Int) -> ReviewSummary? {
        loadStore()[String(productId)]
    }

    private func loadStore() -> [String: ReviewSummary] {
        guard let data = try? Data(contentsOf: fileURL) else { return [:] }
        return (try? decoder.decode([String: ReviewSummary].self, from: data)) ?? [:]
    }
}

private func awaitResult<T>(_ block: @escaping () async throws -> T) -> Result<T, Error> {
    let semaphore = DispatchSemaphore(value: 0)
    var result: Result<T, Error>!
    Task {
        do {
            result = .success(try await block())
        } catch {
            result = .failure(error)
        }
        semaphore.signal()
    }
    semaphore.wait()
    return result
}
