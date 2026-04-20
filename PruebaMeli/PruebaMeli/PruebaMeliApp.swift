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
        let localStore = FileProductLocalStore()
        let repository = ProductAPIRepository(network: network, localStore: localStore)
        let getProductsUseCase = GetProductsUseCase(repository: repository)
        let loadCachedProductsUseCase = LoadCachedProductsUseCase(repository: repository)
        return ProductViewModel(
            getProductsUseCase: getProductsUseCase,
            loadCachedProductsUseCase: loadCachedProductsUseCase
        )
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: productViewModel)
        }
    }
}
