//
//  ProductRepository.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Contrato para obtener productos. El dominio solo conoce este protocolo;
/// quién lo implemente (la API de Walmart, un mock en las pruebas, una caché, etc.)
/// es un detalle de otra capa.
protocol ProductRepository: Sendable {
    /// Busca productos por palabra clave y regresa la página solicitada.
    func searchProducts(keyword: String, page: Int) async throws -> ProductPage
}
