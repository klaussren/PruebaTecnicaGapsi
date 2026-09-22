//
//  HTTPClient.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Cliente HTTP genérico. Protocolo para poder reemplazarlo en pruebas.
protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> Data
}

/// Implementación real usando URLSession.
struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Hace la petición y revisa que la respuesta sea un 2xx.
    /// Los errores de URLSession se convierten a `NetworkError`, salvo la cancelación,
    /// que se deja pasar como `CancellationError` para que la vista la pueda ignorar
    /// (pasa cuando el usuario lanza otra búsqueda antes de que termine la anterior).
    func data(for request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .cancelled:
                throw CancellationError()
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost:
                throw NetworkError.noConnection
            default:
                throw NetworkError.unknown
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}
