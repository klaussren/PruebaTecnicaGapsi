//
//  ClearSearchHistoryUseCase.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Caso de uso: borrar todo el historial de búsquedas.
protocol ClearSearchHistoryUseCase: Sendable {
    func execute()
}

struct DefaultClearSearchHistoryUseCase: ClearSearchHistoryUseCase {
    private let repository: SearchHistoryRepository

    init(repository: SearchHistoryRepository) {
        self.repository = repository
    }

    /// Borra el historial guardando una lista vacía.
    func execute() {
        repository.saveTerms([])
    }
}
