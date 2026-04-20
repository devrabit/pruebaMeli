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

    private let useCase: GetProductsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(useCase: GetProductsUseCase) {
        self.useCase = useCase
    }

    func load() {
        error = nil
        isLoading = true

        useCase.execute()
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
