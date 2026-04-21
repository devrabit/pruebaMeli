//
//  ProductCardView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    let summary: ReviewSummary?
    let isSummaryLoading: Bool
    let summaryError: String?
    let canGenerateSummary: Bool
    let summaryButtonTitle: String
    let onGenerateSummary: () -> Void

    @State private var showSummaryModal = false
    @State private var showAllReviewsModal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            RemoteProductImageView(imageURL: product.image)

            VStack(alignment: .leading, spacing: 0) {
                ProductInfoView(
                    title: product.title,
                    priceText: mockPriceText,
                    averageRating: product.averageRating,
                    reviewCount: product.reviewCount
                )

                if canGenerateSummary {
                    if isSummaryLoading {
                        ProgressView()
                            .padding(.vertical, 4)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Button(summaryButtonTitle, action: onGenerateSummary)
                                .font(.caption.weight(.semibold))
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)

                            if summary != nil {
                                Button("Ver resumen") {
                                    showSummaryModal = true
                                }
                                .padding(.top, 4)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.blue)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                if let summaryError {
                    Text(summaryError)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }
            }
            .padding(8)
        }
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 1)
        .onChange(of: isSummaryLoading) { _, loading in
            if !loading, summary != nil {
                showSummaryModal = true
            }
        }
        .sheet(isPresented: $showSummaryModal) {
            if let summary {
                ReviewSummaryModalView(
                    summary: summary,
                    onDismiss: { showSummaryModal = false },
                    onViewAllReviews: openAllReviews
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showAllReviewsModal) {
            ReviewListView(reviews: product.reviews)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func openAllReviews() {
        showSummaryModal = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showAllReviewsModal = true
        }
    }

    private var mockPriceText: String {
        let basePrice = 19.99 + (Double(product.id % 9) * 5)
        return String(format: "$%.2f", basePrice)
    }
}
