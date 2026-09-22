//
//  WalmartSearchResponseDTO+Mapping.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

extension WalmartSearchResponseDTO {
    /// Convierte la respuesta de la API a una `ProductPage` del dominio.
    /// - Solo tomamos el primer stack (los resultados reales de la búsqueda).
    /// - Si no viene `maxPage`, asumimos que ya no hay más páginas para no pedir de más.
    func toDomain(requestedPage: Int) -> ProductPage {
        let items = searchResult?.itemStacks?.first?.items ?? []
        let products = items.compactMap { $0.toDomain() }
        let totalPages = searchResult?.paginationV2?.maxPage ?? requestedPage

        return ProductPage(
            products: products,
            currentPage: requestedPage,
            totalPages: totalPages
        )
    }
}

extension WalmartProductDTO {
    /// Convierte un elemento de la API a `Product`.
    /// Regresa `nil` para lo que no nos sirve: anuncios, placeholders o productos sin id/nombre.
    func toDomain() -> Product? {
        if let typename, typename != "Product" {
            return nil
        }
        guard let productID = usItemId ?? id,
              let title = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            return nil
        }

        let resolved = resolvedPrice

        return Product(
            id: productID,
            title: title,
            price: resolved?.amount,
            isStartingPrice: resolved?.isStartingPrice ?? false,
            currencyCode: priceInfo?.priceDetails?.currency ?? "USD",
            thumbnailURL: (imageInfo?.thumbnailUrl ?? image).flatMap(URL.init(string:))
        )
    }

    /// Decide qué precio mostrar, en este orden:
    /// 1. "PRICE" de `priceLines`: precio exacto con centavos (actual o con descuento).
    /// 2. "LOW_PRICE": productos con rango de precio (ej. gift cards); se marca como precio inicial.
    /// 3. `price`: valor redondeado, solo como respaldo.
    /// Un precio de 0 se trata como "sin precio", porque así lo manda la API cuando no aplica.
    private var resolvedPrice: (amount: Decimal, isStartingPrice: Bool)? {
        if let amount = priceLineValue(forKey: "PRICE"), amount > 0 {
            return (amount, false)
        }
        if let amount = priceLineValue(forKey: "LOW_PRICE"), amount > 0 {
            return (amount, true)
        }
        if let price, price > 0 {
            return (Decimal(price), false)
        }
        return nil
    }

    /// Busca en `priceLines` el primer valor con la key indicada y lo convierte a `Decimal`.
    /// `en_US_POSIX` asegura que el punto decimal se lea bien sin importar el idioma del teléfono.
    private func priceLineValue(forKey key: String) -> Decimal? {
        let priceText = priceInfo?.priceDetails?.priceLines?
            .lazy
            .compactMap { $0.values?.first(where: { $0.key == key })?.value }
            .first

        guard let priceText else { return nil }
        return Decimal(string: priceText, locale: Locale(identifier: "en_US_POSIX"))
    }
}
