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

    private let getProductsUseCase: GetProductsUseCase
    private let loadCachedProductsUseCase: LoadCachedProductsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(getProductsUseCase: GetProductsUseCase, loadCachedProductsUseCase: LoadCachedProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
        self.loadCachedProductsUseCase = loadCachedProductsUseCase
    }

    func load() {
        let localProducts = loadCachedProductsUseCase.execute()
        if !localProducts.isEmpty {
            products = localProducts
        }

        error = nil
        isLoading = true

        getProductsUseCase.execute()
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
}
