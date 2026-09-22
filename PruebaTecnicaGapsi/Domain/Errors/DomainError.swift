//
//  DomainError.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Los errores que la app entiende, sin importar de dónde vengan.
/// La capa de datos convierte sus errores técnicos (HTTP, URLSession, JSON) a estos casos.
enum DomainError: Error, Equatable {
    /// El usuario intentó buscar sin escribir nada.
    case emptySearchTerm
    /// Se pidió una página menor a 1.
    case invalidPage
    /// No hay internet o se agotó el tiempo de espera.
    case noConnection
    /// La API key no es válida o no está configurada.
    case unauthorized
    /// Se rebasó el límite de peticiones del plan de RapidAPI.
    case tooManyRequests
    /// El servidor respondió con un error (5xx u otro código inesperado).
    case serverError
    /// La respuesta llegó, pero no se pudo interpretar.
    case invalidResponse
}
