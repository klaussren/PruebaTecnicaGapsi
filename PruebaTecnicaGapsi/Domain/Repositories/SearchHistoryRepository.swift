//
//  SearchHistoryRepository.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Contrato para guardar y leer las búsquedas previas del usuario.
/// Solo sabe leer y escribir la lista; las reglas (no repetir, límite, orden)
/// viven en los casos de uso.
protocol SearchHistoryRepository: Sendable {
    /// Regresa las búsquedas guardadas, la más reciente primero.
    func loadTerms() -> [String]
    /// Reemplaza la lista guardada por la que recibe.
    func saveTerms(_ terms: [String])
}
