//
//  ProductGridTemplateView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductGridTemplateView: View {
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

    var body: some View {
        ProductsGridView(
            products: products,
            summaries: summaries,
            loadingSummaryIds: loadingSummaryIds,
            summaryErrors: summaryErrors,
            isLoading: isLoading,
            errorMessage: errorMessage,
            canGenerateSummary: canGenerateSummary,
            summaryButtonTitle: summaryButtonTitle,
            onGenerateSummary: onGenerateSummary,
            onRegenerateSummary: onRegenerateSummary,
            onRetry: onRetry
        )
    }
}
