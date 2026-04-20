//
//  ReviewListView.swift
//  PruebaMeli
//

import SwiftUI

struct ReviewListView: View {
    let reviews: [Review]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Reseñas")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

            if reviews.isEmpty {
                VStack {
                    Spacer()
                    Text("No hay reseñas disponibles")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        ForEach(reviews.indices, id: \.self) { index in
                            ReviewRow(review: reviews[index])
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

private struct ReviewRow: View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 1)
        
    }
}
