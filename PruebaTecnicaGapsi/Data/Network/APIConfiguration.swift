//
//  APIConfiguration.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Datos para conectarnos a la API de RapidAPI (Axesso - Walmart).
struct APIConfiguration: Sendable {
    let baseURL: URL
    let host: String
    let apiKey: String

    /// Arma la configuración leyendo la API key del Info.plist.
    /// El valor viene de Config/Secrets.xcconfig (no se escribe en el código).
    static func fromBundle(_ bundle: Bundle = .main) -> APIConfiguration {
        let host = "axesso-walmart-data-service.p.rapidapi.com"
        let apiKey = bundle.object(forInfoDictionaryKey: "RAPIDAPI_KEY") as? String ?? ""

        return APIConfiguration(
            baseURL: URL(string: "https://\(host)")!,
            host: host,
            apiKey: apiKey
        )
    }
}
