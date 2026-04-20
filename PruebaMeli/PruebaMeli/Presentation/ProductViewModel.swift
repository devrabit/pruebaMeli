//
//  ProductViewModel.swift
//  PruebaMeli
//

import Combine
import Foundation

final class ProductViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var summaries: [Int: ReviewSummary] = [:]
    @Published private(set) var loadingSummaryIds: Set<Int> = []
    @Published private(set) var summaryErrors: [Int: String] = [:]

    private let getProductsUseCase: GetProductsUseCase
    private let loadCachedProductsUseCase: LoadCachedProductsUseCase
    private let generateSummaryUseCase: GenerateReviewSummaryUseCase?
    private let regenerateSummaryUseCase: RegenerateReviewSummaryUseCase?
    private var cancellables = Set<AnyCancellable>()

    init(
        getProductsUseCase: GetProductsUseCase,
        loadCachedProductsUseCase: LoadCachedProductsUseCase,
        generateSummaryUseCase: GenerateReviewSummaryUseCase? = nil,
        regenerateSummaryUseCase: RegenerateReviewSummaryUseCase? = nil
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.loadCachedProductsUseCase = loadCachedProductsUseCase
        self.generateSummaryUseCase = generateSummaryUseCase
        self.regenerateSummaryUseCase = regenerateSummaryUseCase
    }

    func load() {
        let localProducts = loadCachedProductsUseCase.execute()
        if !localProducts.isEmpty {
            products = localProducts
        }

        error = nil
        isLoading = true

        getProductsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let err) = completion {
                    self.error = err.localizedDescription
                }
            } receiveValue: { [weak self] products in
                self?.error = nil
                self?.products = products
            }
            .store(in: &cancellables)
    }

    func canGenerateSummary(for product: Product) -> Bool {
        product.reviews.count > 5
    }

    func summaryButtonTitle(for product: Product) -> String {
        summaries[product.id] == nil ? "Generar resumen" : "Regenerar resumen"
    }

    func generateSummary(for product: Product) {
        guard canGenerateSummary(for: product), let generateSummaryUseCase else { return }
        loadingSummaryIds.insert(product.id)
        summaryErrors[product.id] = nil

        Task { @MainActor in
            do {
                let summary = try await generateSummaryUseCase.execute(product: product)
                summaries[product.id] = summary
            } catch {
                summaryErrors[product.id] = error.localizedDescription
            }
            loadingSummaryIds.remove(product.id)
        }
    }

    func regenerateSummary(for product: Product) {
        guard canGenerateSummary(for: product), let regenerateSummaryUseCase else { return }
        loadingSummaryIds.insert(product.id)
        summaryErrors[product.id] = nil

        Task { @MainActor in
            do {
                let summary = try await regenerateSummaryUseCase.execute(product: product)
                summaries[product.id] = summary
            } catch {
                summaryErrors[product.id] = error.localizedDescription
            }
            loadingSummaryIds.remove(product.id)
        }
    }
}
