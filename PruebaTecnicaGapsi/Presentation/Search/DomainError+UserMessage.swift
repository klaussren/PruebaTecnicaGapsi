//
//  DomainError+UserMessage.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

extension DomainError {
    /// Texto que ve el usuario para cada error.
    /// Está en la capa de presentación porque es algo de la interfaz, no del negocio.
    /// `String(localized:)` busca la traducción en Localizable.xcstrings según el idioma del teléfono.
    var userMessage: String {
        switch self {
        case .emptySearchTerm:
            return String(localized: "Escribe algo para buscar.")
        case .invalidPage:
            return String(localized: "No se pudo cargar esa página de resultados.")
        case .noConnection:
            return String(localized: "Parece que no tienes conexión a internet. Revisa tu conexión e intenta de nuevo.")
        case .unauthorized:
            return String(localized: "El servicio rechazó la consulta. Revisa que la API key esté configurada en Config/Secrets.xcconfig.")
        case .tooManyRequests:
            return String(localized: "Se alcanzó el límite de consultas del servicio. Espera un momento e intenta de nuevo.")
        case .serverError:
            return String(localized: "El servicio no está disponible en este momento. Intenta más tarde.")
        case .invalidResponse:
            return String(localized: "No pudimos leer la respuesta del servicio. Intenta de nuevo.")
        }
    }
}
