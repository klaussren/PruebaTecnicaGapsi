//
//  WalmartEndpoint.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//
import Foundation

/// Construcción de requests para la API de Walmart (ruta, query params y headers).
enum WalmartEndpoint {
    /// Request para `walmart-search-by-keyword`, con la key en el header `x-rapidapi-key`.
    static func searchByKeyword(
        _ keyword: String,
        page: Int,
        sortBy: String = "best_match",
        configuration: APIConfiguration
    ) throws -> URLRequest {
        var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent("wlm/walmart-search-by-keyword"),
            resolvingAgainstBaseURL: false
        )
        // URLComponents escapa espacios y caracteres especiales.
        components?.queryItems = [
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sortBy", value: sortBy)
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "GET"
        request.setValue(configuration.apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(configuration.host, forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
