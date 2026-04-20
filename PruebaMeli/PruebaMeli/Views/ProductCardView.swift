//
//  ProductCardView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            AsyncImage(url: URL(string: product.image)) { phase in
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
            .frame(height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading) {
                Text(product.title)
                    .font(.system(size: 29 * 0.5, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(mockPriceText)
                    .font(.system(size: 36 * 0.5, weight: .bold))
                    .foregroundStyle(.primary)

                HStack(alignment: .center, spacing: 4) {
                    StarRatingView(rating: product.averageRating, maxRating: 5)

                    Text(reviewCountLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.secondary)
                }
                .padding(.bottom, 20)
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 1)
    }

    private var reviewCountLabel: String {
        "(\(product.reviewCount) reseñas)"
    }

    private var mockPriceText: String {
        // Temporary visual placeholder while price is not part of domain model.
        let basePrice = 19.99 + (Double(product.id % 9) * 5)
        return String(format: "$%.2f", basePrice)
    }
}
