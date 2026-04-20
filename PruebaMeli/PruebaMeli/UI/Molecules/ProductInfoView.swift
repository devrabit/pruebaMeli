//
//  ProductInfoView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductInfoView: View {
    let title: String
    let priceText: String
    let averageRating: Double
    let reviewCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 29 * 0.5, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(priceText)
                .font(.system(size: 36 * 0.5, weight: .bold))
                .foregroundStyle(.primary)

            HStack(alignment: .center, spacing: 4) {
                StarRatingView(rating: averageRating, maxRating: 5)
                Text("(\(reviewCount) reseñas)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
