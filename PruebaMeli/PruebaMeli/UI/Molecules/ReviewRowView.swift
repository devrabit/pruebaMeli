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
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 1)
    }
}
