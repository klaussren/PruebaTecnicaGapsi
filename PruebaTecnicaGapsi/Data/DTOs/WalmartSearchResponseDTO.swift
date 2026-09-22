//
//  WalmartSearchResponseDTO.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Respuesta de `walmart-search-by-keyword`.
/// El JSON es enorme y viene muy anidado; aquí solo declaramos el camino que nos interesa:
/// `item.props.pageProps.initialData.searchResult` → `itemStacks` (productos) y `paginationV2` (páginas).
/// Todo es opcional porque el servicio no siempre manda todos los campos.
struct WalmartSearchResponseDTO: Decodable {
    let item: Item?

    struct Item: Decodable {
        let props: Props?
    }

    struct Props: Decodable {
        let pageProps: PageProps?
    }

    struct PageProps: Decodable {
        let initialData: InitialData?
    }

    struct InitialData: Decodable {
        let searchResult: SearchResult?
    }

    struct SearchResult: Decodable {
        let itemStacks: [ItemStack]?
        let paginationV2: Pagination?
    }

    /// Un "stack" es un bloque de resultados. El primero son los resultados de la búsqueda;
    /// los demás suelen ser carruseles como "Highly rated", que repiten productos.
    struct ItemStack: Decodable {
        let items: [WalmartProductDTO]?
    }

    struct Pagination: Decodable {
        let maxPage: Int?
    }

    /// Acceso directo a `searchResult`.
    var searchResult: SearchResult? {
        item?.props?.pageProps?.initialData?.searchResult
    }
}
