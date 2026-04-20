//
//  ProductsGridView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductsGridView: View {
    let products: [Product]
    let summaries: [Int: ReviewSummary]
    let loadingSummaryIds: Set<Int>
    let summaryErrors: [Int: String]
    let isLoading: Bool
    let errorMessage: String?
    let canGenerateSummary: (Product) -> Bool
    let summaryButtonTitle: (Product) -> String
    let onGenerateSummary: (Product) -> Void
    let onRegenerateSummary: (Product) -> Void
    let onRetry: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(products) { product in
                    ProductCardView(
                        product: product,
                        summary: summaries[product.id],
                        isSummaryLoading: loadingSummaryIds.contains(product.id),
                        summaryError: summaryErrors[product.id],
                        canGenerateSummary: canGenerateSummary(product),
                        summaryButtonTitle: summaryButtonTitle(product),
                        onGenerateSummary: {
                            if summaries[product.id] == nil {
                                onGenerateSummary(product)
                            } else {
                                onRegenerateSummary(product)
                            }
                        }
                    )
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
