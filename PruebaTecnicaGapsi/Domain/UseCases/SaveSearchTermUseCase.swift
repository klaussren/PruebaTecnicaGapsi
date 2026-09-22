//
//  SaveSearchTermUseCase.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Caso de uso: guardar una palabra en el historial de búsquedas.
protocol SaveSearchTermUseCase: Sendable {
    /// Guarda el término y regresa cómo quedó el historial.
    @discardableResult
    func execute(term: String) -> [String]
}

struct DefaultSaveSearchTermUseCase: SaveSearchTermUseCase {
    /// Cuántas búsquedas guardamos como máximo, para que la lista no crezca sin fin.
    static let defaultMaxTerms = 15

    private let repository: SearchHistoryRepository
    private let maxTerms: Int

    init(repository: SearchHistoryRepository, maxTerms: Int = DefaultSaveSearchTermUseCase.defaultMaxTerms) {
        self.repository = repository
        self.maxTerms = maxTerms
    }

    /// Guarda el término al inicio de la lista. Ignora textos vacíos, evita duplicados
    /// (sin distinguir mayúsculas) y recorta la lista al máximo permitido.
    @discardableResult
    func execute(term: String) -> [String] {
        let cleanTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        var terms = repository.loadTerms()

        guard !cleanTerm.isEmpty else {
            return terms
        }

        terms.removeAll { $0.caseInsensitiveCompare(cleanTerm) == .orderedSame }
        terms.insert(cleanTerm, at: 0)

        if terms.count > maxTerms {
            terms = Array(terms.prefix(maxTerms))
        }

        repository.saveTerms(terms)
        return terms
    }
}
