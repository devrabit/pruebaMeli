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
                    productList
                } else if let message = viewModel.error {
                    errorState(message: message)
                } else {
                    emptyState
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

    private var productList: some View {
        List(viewModel.products) { product in
            HStack(alignment: .top, spacing: 12) {
                productThumbnail(urlString: product.image)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 6) {
                    Text(product.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text(reviewCountLabel(product.reviews.count))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let message = viewModel.error {
                errorBanner(message: message)
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(10)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private func errorBanner(message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(message, systemImage: "wifi.exclamationmark")
                .font(.subheadline)
                .foregroundStyle(.primary)
            Button("Reintentar") {
                viewModel.load()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.orange.opacity(0.15))
    }

    private func productThumbnail(urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.secondary.opacity(0.12))
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.secondary.opacity(0.12))
            @unknown default:
                EmptyView()
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Sin productos", systemImage: "cube.box")
        } description: {
            Text("El servidor devolvió una lista vacía. En Proxyman, mapea GET /products al fixture Mocks/Products/list.json o revisa BASE_URL.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(message: String) -> some View {
        ContentUnavailableView {
            Label("Error de red", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Reintentar") {
                viewModel.load()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func reviewCountLabel(_ count: Int) -> String {
        switch count {
        case 0: return "Sin reseñas"
        case 1: return "1 reseña"
        default: return "\(count) reseñas"
        }
    }
}

#Preview {
    let mockRepo = PreviewMockRepository()
    let vm = ProductViewModel(useCase: GetProductsUseCase(repository: mockRepo))
    return ContentView(viewModel: vm)
}

private final class PreviewMockRepository: ProductRepository {
    func fetchProducts() -> AnyPublisher<[Product], Error> {
        let sample = (1...5).map { i in
            Product(
                id: i,
                title: "Producto de ejemplo \(i)",
                image: "https://picsum.photos/seed/\(i)/200/200",
                reviews: (0..<(i % 4)).map { r in
                    Review(author: "Usuario \(r)", rating: ((r % 5) + 1), text: "Buen producto.")
                }
            )
        }
        return Just(sample)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
