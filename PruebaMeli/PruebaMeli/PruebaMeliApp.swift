//
//  PruebaMeliApp.swift
//  PruebaMeli
//
//  Created by Andrey Carreño on 19/04/26.
//

import SwiftUI

@main
struct PruebaMeliApp: App {
    private let productViewModel: ProductViewModel = {
        let network = URLSessionNetworkClient()
        let repository = ProductAPIRepository(network: network)
        let useCase = GetProductsUseCase(repository: repository)
        return ProductViewModel(useCase: useCase)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: productViewModel)
        }
    }
}
