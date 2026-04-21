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
        let summaryRepository = FileSummaryRepository()
        let summaryGenerator = OnDeviceSummaryGenerator()
        let repository = ProductAPIRepository(network: network, localStore: localStore)
        let getProductsUseCase = GetProductsUseCase(repository: repository)
        let loadCachedProductsUseCase = LoadCachedProductsUseCase(repository: repository)
        let generateSummaryUseCase = GenerateReviewSummaryUseCase(
            generator: summaryGenerator,
            repository: summaryRepository
        )
        let regenerateSummaryUseCase = RegenerateReviewSummaryUseCase(
            generator: summaryGenerator,
            repository: summaryRepository
        )
        return ProductViewModel(
            getProductsUseCase: getProductsUseCase,
            loadCachedProductsUseCase: loadCachedProductsUseCase,
            summaryRepository: summaryRepository,
            generateSummaryUseCase: generateSummaryUseCase,
            regenerateSummaryUseCase: regenerateSummaryUseCase
        )
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: productViewModel)
        }
    }
}
