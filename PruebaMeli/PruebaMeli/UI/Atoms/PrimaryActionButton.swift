//
//  PrimaryActionButton.swift
//  PruebaMeli
//

import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.12, green: 0.18, blue: 0.32))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
