//
//  AppContainer.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Contenedor de dependencias: crea las implementaciones concretas y las inyecta por protocolo.
/// URLSession, Walmart, UserDefaults y NWPathMonitor solo se referencian desde este archivo.
@MainActor
final class AppContainer {
    private let productRepository: ProductRepository
    private let searchHistoryRepository: SearchHistoryRepository
    /// Una sola instancia para toda la app; la comparten el caso de uso y la pantalla.
    private let connectivityMonitor: ConnectivityMonitor

    init(
        configuration: APIConfiguration = .fromBundle(),
        httpClient: HTTPClient = URLSessionHTTPClient(),
        userDefaults: UserDefaults = .standard,
        connectivityMonitor: ConnectivityMonitor = NWPathConnectivityMonitor()
    ) {
        self.connectivityMonitor = connectivityMonitor
        productRepository = WalmartProductRepository(httpClient: httpClient, configuration: configuration)
        searchHistoryRepository = UserDefaultsSearchHistoryRepository(userDefaults: userDefaults)
    }

    /// Crea el ViewModel de la búsqueda con todos sus casos de uso.
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            searchProductsUseCase: DefaultSearchProductsUseCase(
                repository: productRepository,
                connectivity: connectivityMonitor
            ),
            getSearchHistoryUseCase: DefaultGetSearchHistoryUseCase(repository: searchHistoryRepository),
            saveSearchTermUseCase: DefaultSaveSearchTermUseCase(repository: searchHistoryRepository),
            clearSearchHistoryUseCase: DefaultClearSearchHistoryUseCase(repository: searchHistoryRepository),
            connectivityMonitor: connectivityMonitor
        )
    }
}
