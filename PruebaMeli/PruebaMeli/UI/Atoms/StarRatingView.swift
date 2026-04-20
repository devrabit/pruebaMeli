//
//  StarRatingView.swift
//  PruebaMeli
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let maxRating: Int
    var size: CGFloat = 11
    var spacing: CGFloat = 1
    var color: Color = Color(red: 0.95, green: 0.74, blue: 0.17)

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: starName(for: index))
                    .font(.system(size: size))
                    .foregroundStyle(color)
            }
        }
    }

    private func starName(for index: Int) -> String {
        let threshold = Double(index + 1)
        if rating >= threshold {
            return "star.fill"
        }
        if rating >= (threshold - 0.5) {
            return "star.leadinghalf.filled"
        }
        return "star"
    }
}
