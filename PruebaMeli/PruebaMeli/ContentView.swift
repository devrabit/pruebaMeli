//
//  ContentView.swift
//  PruebaMeli
//
//  Created by Andrey Carreño on 19/04/26.
//

import Combine
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ProductViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView("Cargando…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.products.isEmpty {
                    ProductsGridView(
                        products: viewModel.products,
                        summaries: viewModel.summaries,
                        loadingSummaryIds: viewModel.loadingSummaryIds,
                        summaryErrors: viewModel.summaryErrors,
                        isLoading: viewModel.isLoading,
                        errorMessage: viewModel.error,
                        canGenerateSummary: viewModel.canGenerateSummary,
                        summaryButtonTitle: viewModel.summaryButtonTitle,
                        onGenerateSummary: viewModel.generateSummary,
                        onRegenerateSummary: viewModel.regenerateSummary,
                        onRetry: viewModel.load
                    )
                } else if let message = viewModel.error {
                    ProductErrorStateView(message: message, onRetry: viewModel.load)
                } else {
                    ProductEmptyStateView()
                }
            }
            .navigationTitle("Productos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.load()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .task {
            viewModel.load()
        }
    }
}

#Preview {
    let mockRepo = PreviewMockRepository()
    let vm = ProductViewModel(
        getProductsUseCase: GetProductsUseCase(repository: mockRepo),
        loadCachedProductsUseCase: LoadCachedProductsUseCase(repository: mockRepo)
    )
    return ContentView(viewModel: vm)
}

private final class PreviewMockRepository: ProductRepository {
    private var cache: [Product] = []

    func fetchProducts() -> AnyPublisher<[Product], Error> {
        let sample = (1...20).map { i in
            Product(
                id: i,
                title: "Producto de ejemplo \(i)",
                image: "https://picsum.photos/seed/\(i)/200/200",
                reviews: (0..<(i % 6)).map { r in
                    Review(author: "Usuario \(r)", rating: ((r % 5) + 1), text: "Buen producto.")
                }
            )
        }
        return Just(sample)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func saveProducts(_ products: [Product]) {
        cache = products
    }

    func loadLocalProducts() -> [Product] {
        cache
    }
}
