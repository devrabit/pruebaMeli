//
//  ProductsGridView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductsGridView: View {
    let products: [Product]
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(products) { product in
                    ProductCardView(product: product)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let errorMessage {
                ProductErrorBannerView(message: errorMessage, onRetry: onRetry)
            }
        }
        .overlay(alignment: .center) {
            if isLoading {
                ProgressView()
                    .padding(10)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}
