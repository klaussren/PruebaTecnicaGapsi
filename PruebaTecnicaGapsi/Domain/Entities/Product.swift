//
//  Product.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Un producto tal cual lo necesita la app: título, precio e imagen.
/// Esta estructura no sabe nada de la API de Walmart; si el JSON cambia,
/// solo se ajusta el mapeo en la capa de datos y esto se queda igual.
struct Product: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    /// Puede venir vacío si el servicio no manda precio para ese producto.
    let price: Decimal?
    /// `true` cuando `price` es el precio mínimo de un rango (ej. gift cards de $10 a $250).
    let isStartingPrice: Bool
    let currencyCode: String
    let thumbnailURL: URL?
}
