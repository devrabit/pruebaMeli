//
//  ReviewRowView.swift
//  PruebaMeli
//

import SwiftUI

struct ReviewRowView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(review.author)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            StarRatingView(
                rating: Double(review.rating),
                maxRating: 5,
                size: 12,
                spacing: 2
            )

            Text(review.text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
