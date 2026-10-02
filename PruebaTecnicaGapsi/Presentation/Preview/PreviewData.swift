//
//  PreviewData.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

#if DEBUG
import Foundation

/// Datos e implementaciones falsas para los previews del Canvas.
/// Solo se compila en Debug, no forma parte de la app que se publica.
enum PreviewData {

    static let products: [Product] = [
        Product(
            id: "21944233",
            title: "Restored Nintendo Wii Console, White (Refurbished)",
            price: Decimal(string: "69.99"),
            isStartingPrice: false,
            currencyCode: "USD",
            thumbnailURL: URL(string: "https://i5.walmartimages.com/asr/d3a5a033-9930-45ef-ba77-888784978353.b16107bcaa1b52c9a5ce20c64946a0b8.jpeg")
        ),
        Product(
            id: "15949610846",
            title: "Nintendo Switch 2 System",
            price: 499,
            isStartingPrice: false,
            currencyCode: "USD",
            thumbnailURL: URL(string: "https://i5.walmartimages.com/seo/Nintendo-Switch-2-System_e54b513c-cf10-44a5-8a78-14a5f70644a8.dca71e01a5172a18dbc2bc689f959469.jpeg")
        ),
        Product(
            id: "gift-card",
            title: "Sony PlayStation VGC $10-$250 [Digital]",
            price: 10,
            isStartingPrice: true,
            currencyCode: "USD",
            thumbnailURL: nil
        ),
        Product(
            id: "no-price",
            title: "Producto sin precio",
            price: nil,
            isStartingPrice: false,
            currencyCode: "USD",
            thumbnailURL: nil
        )
    ]

    static let history = ["nintendo", "sony", "computer"]

    /// ViewModel listo para el Canvas, con casos de uso en memoria (no llama a la API).
    @MainActor
    static func makeSearchViewModel(
        history: [String] = PreviewData.history,
        products: [Product] = PreviewData.products,
        isConnected: Bool = true
    ) -> SearchViewModel {
        let historyRepository = InMemorySearchHistoryRepository(terms: history)
        let connectivity = FixedConnectivityMonitor(isConnected: isConnected)

        return SearchViewModel(
            searchProductsUseCase: DefaultSearchProductsUseCase(
                repository: StubProductRepository(products: products),
                connectivity: connectivity
            ),
            getSearchHistoryUseCase: DefaultGetSearchHistoryUseCase(repository: historyRepository),
            saveSearchTermUseCase: DefaultSaveSearchTermUseCase(repository: historyRepository),
            clearSearchHistoryUseCase: DefaultClearSearchHistoryUseCase(repository: historyRepository),
            connectivityMonitor: connectivity
        )
    }
}

/// Regresa siempre los mismos productos en una sola página.
private struct StubProductRepository: ProductRepository {
    let products: [Product]

    func searchProducts(keyword: String, page: Int) async throws -> ProductPage {
        ProductPage(products: products, currentPage: page, totalPages: 1)
    }
}

/// Historial en memoria para no tocar el UserDefaults real desde el Canvas.
private final class InMemorySearchHistoryRepository: SearchHistoryRepository, @unchecked Sendable {
    private var terms: [String]

    init(terms: [String]) {
        self.terms = terms
    }

    func loadTerms() -> [String] {
        terms
    }

    func saveTerms(_ terms: [String]) {
        self.terms = terms
    }
}

/// Conexión fija: permite ver la pantalla con o sin internet.
private struct FixedConnectivityMonitor: ConnectivityMonitor {
    let isConnected: Bool

    func statusUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(isConnected)
            continuation.finish()
        }
    }
}
#endif
