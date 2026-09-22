//
//  WalmartProductDTO.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Un elemento dentro de `itemStacks[].items`.
/// Además de productos, la lista incluye anuncios y placeholders (se distinguen por `__typename`).
struct WalmartProductDTO: Decodable {
    let typename: String?
    let id: String?
    let usItemId: String?
    let name: String?
    /// Precio redondeado que manda Walmart (ej. 69 en lugar de 69.99). Solo lo usamos de respaldo.
    let price: Double?
    let image: String?
    let imageInfo: ImageInfo?
    let priceInfo: PriceInfo?

    struct ImageInfo: Decodable {
        let thumbnailUrl: String?
    }

    struct PriceInfo: Decodable {
        let priceDetails: PriceDetails?
    }

    struct PriceDetails: Decodable {
        let currency: String?
        let priceLines: [PriceLine]?
    }

    /// Cada línea de precio trae un tipo (precio actual, precio con descuento, precio anterior...)
    /// y sus valores como texto, por ejemplo `{ "key": "PRICE", "value": "69.99" }`.
    struct PriceLine: Decodable {
        let lineType: String?
        let values: [PriceValue]?
    }

    struct PriceValue: Decodable {
        let key: String?
        let value: String?
    }

    private enum CodingKeys: String, CodingKey {
        case typename = "__typename"
        case id, usItemId, name, price, image, imageInfo, priceInfo
    }

    /// Decodificación tolerante: si un campo trae un tipo inesperado se ignora ese campo
    /// en lugar de fallar toda la página.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        typename = try? container.decodeIfPresent(String.self, forKey: .typename)
        id = try? container.decodeIfPresent(String.self, forKey: .id)
        usItemId = try? container.decodeIfPresent(String.self, forKey: .usItemId)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        price = try? container.decodeIfPresent(Double.self, forKey: .price)
        image = try? container.decodeIfPresent(String.self, forKey: .image)
        imageInfo = try? container.decodeIfPresent(ImageInfo.self, forKey: .imageInfo)
        priceInfo = try? container.decodeIfPresent(PriceInfo.self, forKey: .priceInfo)
    }
}
