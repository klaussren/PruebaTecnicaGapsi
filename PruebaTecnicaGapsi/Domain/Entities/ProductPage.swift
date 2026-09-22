//
//  ProductPage.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Una página de resultados de búsqueda.
/// Además de los productos guardamos en qué página vamos y cuántas hay,
/// que es lo que necesitamos para ir cargando más conforme el usuario hace scroll.
struct ProductPage: Equatable, Sendable {
    let products: [Product]
    let currentPage: Int
    let totalPages: Int

    /// Nos dice si todavía quedan páginas por pedir.
    var hasMorePages: Bool {
        currentPage < totalPages
    }
}
