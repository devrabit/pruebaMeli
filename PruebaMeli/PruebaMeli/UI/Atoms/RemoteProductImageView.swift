//
//  RemoteProductImageView.swift
//  PruebaMeli
//

import SwiftUI

struct RemoteProductImageView: View {
    let imageURL: String
    var height: CGFloat = 132

    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
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
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}
