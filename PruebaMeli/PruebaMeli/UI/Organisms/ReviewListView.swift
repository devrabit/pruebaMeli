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
                            ReviewRowView(review: reviews[index])
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
