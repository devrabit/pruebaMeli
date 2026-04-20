//
//  ProductPageView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductPageView: View {
    @ObservedObject var viewModel: ProductViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.products.isEmpty {
                ProductGridTemplateView(
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
    }
}
