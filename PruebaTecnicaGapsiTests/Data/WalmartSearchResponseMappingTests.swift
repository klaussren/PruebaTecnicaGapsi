//
//  WalmartSearchResponseMappingTests.swift
//  PruebaTecnicaGapsiTests
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import XCTest
@testable import PruebaTecnicaGapsi

/// Valida que el JSON de Walmart se convierta bien a entidades del dominio.
/// El JSON es una versión recortada de una respuesta real de la API.
final class WalmartSearchResponseMappingTests: XCTestCase {

    func test_toDomain_mapsOnlyProductsFromFirstStack() throws {
        let page = try decode(Self.sampleJSON).toDomain(requestedPage: 1)

        // El anuncio (AdPlaceholder) y el carrusel del segundo stack se descartan.
        XCTAssertEqual(page.products.map(\.id), ["21944233", "15949610846"])
        XCTAssertEqual(page.currentPage, 1)
        XCTAssertEqual(page.totalPages, 13)
        XCTAssertTrue(page.hasMorePages)
    }

    func test_toDomain_usesExactPriceFromPriceLines() throws {
        let product = try XCTUnwrap(decode(Self.sampleJSON).toDomain(requestedPage: 1).products.first)

        XCTAssertEqual(product.title, "Restored Nintendo Wii Console, White (Refurbished)")
        XCTAssertEqual(product.price, Decimal(string: "69.99"))
        XCTAssertEqual(product.currencyCode, "USD")
        XCTAssertEqual(product.thumbnailURL?.absoluteString, "https://i5.walmartimages.com/asr/wii.jpeg?odnHeight=240&odnWidth=240&odnBg=FFFFFF")
    }

    func test_toDomain_withoutPriceLines_fallsBackToRoundedPriceAndImage() throws {
        let product = try XCTUnwrap(decode(Self.sampleJSON).toDomain(requestedPage: 1).products.last)

        XCTAssertEqual(product.price, Decimal(499))
        XCTAssertEqual(product.thumbnailURL?.absoluteString, "https://i5.walmartimages.com/seo/switch2.jpeg?odnHeight=240&odnWidth=240&odnBg=FFFFFF")
    }

    /// Caso real de la API: gift card "PlayStation VGC $10-$250" con price = 0 y solo LOW_PRICE.
    func test_toDomain_withOnlyLowPrice_usesItAsStartingPrice() throws {
        let json = #"{"__typename":"Product","usItemId":"1","name":"Sony PlayStation VGC $10-$250","price":0,"priceInfo":{"priceDetails":{"currency":"USD","priceLines":[{"lineType":"OPTIONS","values":[{"key":"LOW_PRICE","value":"10.00"}]}]}}}"#
        let product = try XCTUnwrap(decodeProduct(json).toDomain())

        XCTAssertEqual(product.price, Decimal(string: "10.00"))
        XCTAssertTrue(product.isStartingPrice)
    }

    /// Si la API manda 0 y ningún otro precio, se muestra como "sin precio" en lugar de $0.00.
    func test_toDomain_withZeroPrice_returnsNilPrice() throws {
        let json = #"{"__typename":"Product","usItemId":"2","name":"Producto sin precio","price":0}"#
        let product = try XCTUnwrap(decodeProduct(json).toDomain())

        XCTAssertNil(product.price)
        XCTAssertFalse(product.isStartingPrice)
    }

    /// Cuando hay PRICE y también LOW_PRICE, manda el precio exacto.
    func test_toDomain_withPriceAndLowPrice_prefersExactPrice() throws {
        let json = #"{"__typename":"Product","usItemId":"3","name":"Nintendo 64","price":109,"priceInfo":{"priceDetails":{"priceLines":[{"lineType":"CURRENT_PRICE","values":[{"key":"PRICE","value":"109.99"}]},{"lineType":"OPTIONS","values":[{"key":"LOW_PRICE","value":"103.95"}]}]}}}"#
        let product = try XCTUnwrap(decodeProduct(json).toDomain())

        XCTAssertEqual(product.price, Decimal(string: "109.99"))
        XCTAssertFalse(product.isStartingPrice)
    }

    /// Si la URL ya trae parámetros de tamaño (180), se reemplazan por los nuestros sin duplicarlos.
    func test_thumbnailURL_replacesExistingSizeParameters() {
        let url = WalmartProductDTO.thumbnailURL(from: "https://i5.walmartimages.com/seo/n64.jpeg?odnHeight=180&odnWidth=180&odnBg=FFFFFF")

        XCTAssertEqual(url?.absoluteString, "https://i5.walmartimages.com/seo/n64.jpeg?odnHeight=240&odnWidth=240&odnBg=FFFFFF")
    }

    /// Las imágenes que no son de Walmart no se modifican.
    func test_thumbnailURL_withOtherDomain_keepsURLUnchanged() {
        let url = WalmartProductDTO.thumbnailURL(from: "https://example.com/image.jpg")

        XCTAssertEqual(url?.absoluteString, "https://example.com/image.jpg")
    }

    func test_toDomain_withNoResults_returnsEmptyPageWithoutMorePages() throws {
        let json = #"{"item":{"props":{"pageProps":{"initialData":{"searchResult":{"itemStacks":[{"items":[]}],"paginationV2":{"maxPage":0}}}}}}}"#

        let page = try decode(json).toDomain(requestedPage: 1)

        XCTAssertTrue(page.products.isEmpty)
        XCTAssertFalse(page.hasMorePages)
    }

    // MARK: - Helpers

    private func decode(_ json: String) throws -> WalmartSearchResponseDTO {
        try JSONDecoder().decode(WalmartSearchResponseDTO.self, from: Data(json.utf8))
    }

    private func decodeProduct(_ json: String) throws -> WalmartProductDTO {
        try JSONDecoder().decode(WalmartProductDTO.self, from: Data(json.utf8))
    }

    private static let sampleJSON = """
    {
      "responseStatus": "PRODUCT_FOUND_RESPONSE",
      "item": { "props": { "pageProps": { "initialData": { "searchResult": {
        "paginationV2": { "maxPage": 13 },
        "itemStacks": [
          { "items": [
            {
              "__typename": "Product", "id": "4DCBAOD6ATAG", "usItemId": "21944233",
              "name": "Restored Nintendo Wii Console, White (Refurbished)", "price": 69,
              "image": "https://i5.walmartimages.com/asr/wii-big.jpeg",
              "imageInfo": { "thumbnailUrl": "https://i5.walmartimages.com/asr/wii.jpeg" },
              "priceInfo": { "priceDetails": { "currency": "USD", "priceLines": [
                { "lineType": "CURRENT_PRICE", "values": [ { "key": "PRICE", "value": "69.99" } ] }
              ] } }
            },
            { "__typename": "AdPlaceholder", "id": "ad-1" },
            {
              "__typename": "Product", "id": "2ZGRGZ46D361", "usItemId": "15949610846",
              "name": "Nintendo Switch 2 System", "price": 499,
              "image": "https://i5.walmartimages.com/seo/switch2.jpeg",
              "priceInfo": { "priceDetails": { "currency": "USD", "priceLines": [] } }
            }
          ] },
          { "items": [
            { "__typename": "Product", "usItemId": "999", "name": "Carrusel Highly rated", "price": 10 }
          ] }
        ]
      } } } } }
    }
    """
}
