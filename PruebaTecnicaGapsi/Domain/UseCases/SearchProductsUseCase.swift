//
//  SearchProductsUseCase.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Caso de uso: buscar productos por texto.
protocol SearchProductsUseCase: Sendable {
    func execute(keyword: String, page: Int) async throws -> ProductPage
}

struct DefaultSearchProductsUseCase: SearchProductsUseCase {
    private let repository: ProductRepository
    private let connectivity: ConnectivityChecker

    init(repository: ProductRepository, connectivity: ConnectivityChecker) {
        self.repository = repository
        self.connectivity = connectivity
    }

    /// Valida todo antes de ir al servicio:
    /// - Quitamos espacios de más para no mandar búsquedas como "  sony  ".
    /// - Si el texto queda vacío o la página no tiene sentido, no llamamos a la API.
    /// - Si no hay internet avisamos de inmediato, en lugar de esperar a que la petición falle.
    func execute(keyword: String, page: Int) async throws -> ProductPage {
        let cleanKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanKeyword.isEmpty else {
            throw DomainError.emptySearchTerm
        }
        guard page >= 1 else {
            throw DomainError.invalidPage
        }
        guard connectivity.isConnected else {
            throw DomainError.noConnection
        }

        return try await repository.searchProducts(keyword: cleanKeyword, page: page)
    }
}
