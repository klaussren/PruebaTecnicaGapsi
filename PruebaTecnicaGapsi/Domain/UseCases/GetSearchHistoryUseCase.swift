//
//  GetSearchHistoryUseCase.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Caso de uso: obtener las búsquedas previas del usuario.
protocol GetSearchHistoryUseCase: Sendable {
    func execute() -> [String]
}

struct DefaultGetSearchHistoryUseCase: GetSearchHistoryUseCase {
    private let repository: SearchHistoryRepository

    init(repository: SearchHistoryRepository) {
        self.repository = repository
    }

    /// Regresa el historial, de la búsqueda más reciente a la más antigua.
    func execute() -> [String] {
        repository.loadTerms()
    }
}
