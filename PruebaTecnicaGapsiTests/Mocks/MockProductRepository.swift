//
//  MockProductRepository.swift
//  PruebaTecnicaGapsiTests
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation
@testable import PruebaTecnicaGapsi

/// Repositorio falso para probar los casos de uso sin llamar a la API.
/// Le decimos qué regresar (`result`) y después revisamos con qué lo llamaron.
final class MockProductRepository: ProductRepository, @unchecked Sendable {
    var result: Result<ProductPage, Error>
    private(set) var searchCallCount = 0
    private(set) var receivedKeyword: String?
    private(set) var receivedPage: Int?

    init(result: Result<ProductPage, Error> = .success(.stub())) {
        self.result = result
    }

    func searchProducts(keyword: String, page: Int) async throws -> ProductPage {
        searchCallCount += 1
        receivedKeyword = keyword
        receivedPage = page
        return try result.get()
    }
}

extension Product {
    /// Producto de ejemplo para las pruebas.
    static func stub(id: String = "1", title: String = "Nintendo Switch", price: Decimal? = 299.99) -> Product {
        Product(
            id: id,
            title: title,
            price: price,
            isStartingPrice: false,
            currencyCode: "USD",
            thumbnailURL: URL(string: "https://example.com/\(id).jpg")
        )
    }
}

extension ProductPage {
    /// Página de ejemplo para las pruebas.
    static func stub(products: [Product] = [.stub()], currentPage: Int = 1, totalPages: Int = 3) -> ProductPage {
        ProductPage(products: products, currentPage: currentPage, totalPages: totalPages)
    }
}
