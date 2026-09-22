//
//  WalmartProductRepository.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Implementación de `ProductRepository` que consulta la API de Walmart en RapidAPI.
struct WalmartProductRepository: ProductRepository {
    private let httpClient: HTTPClient
    private let configuration: APIConfiguration

    init(httpClient: HTTPClient, configuration: APIConfiguration) {
        self.httpClient = httpClient
        self.configuration = configuration
    }

    /// Arma el request, lo manda, decodifica el JSON y lo convierte a entidades del dominio.
    /// Como esta función no está atada al MainActor, la descarga y el parseo del JSON
    /// (que pesa casi 1 MB) corren fuera del hilo principal y la pantalla no se congela.
    func searchProducts(keyword: String, page: Int) async throws -> ProductPage {
        do {
            let request = try WalmartEndpoint.searchByKeyword(keyword, page: page, configuration: configuration)
            let data = try await httpClient.data(for: request)
            let response = try JSONDecoder().decode(WalmartSearchResponseDTO.self, from: data)
            return response.toDomain(requestedPage: page)
        } catch let error as NetworkError {
            throw error.asDomainError
        } catch is DecodingError {
            throw DomainError.invalidResponse
        }
    }
}
