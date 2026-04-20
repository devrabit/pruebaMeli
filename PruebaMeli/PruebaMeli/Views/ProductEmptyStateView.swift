//
//  ProductEmptyStateView.swift
//  PruebaMeli
//

import SwiftUI

struct ProductEmptyStateView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Sin productos", systemImage: "cube.box")
        } description: {
            Text("El servidor devolvió una lista vacía. En Proxyman, mapea GET /products al fixture Mocks/Products/list.json o revisa BASE_URL.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
