//
//  NetworkError.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Errores técnicos de red. Se quedan en la capa de datos;
/// el repositorio los convierte a `DomainError` antes de subirlos.
enum NetworkError: Error, Equatable {
    case invalidURL
    case noConnection
    case invalidResponse
    case httpError(statusCode: Int)
    case unknown
}

extension NetworkError {
    /// Traduce el error técnico a uno que el resto de la app entienda.
    var asDomainError: DomainError {
        switch self {
        case .noConnection:
            return .noConnection
        case .httpError(let statusCode) where statusCode == 401 || statusCode == 403:
            return .unauthorized
        case .httpError(statusCode: 429):
            return .tooManyRequests
        case .httpError, .unknown:
            return .serverError
        case .invalidURL, .invalidResponse:
            return .invalidResponse
        }
    }
}
