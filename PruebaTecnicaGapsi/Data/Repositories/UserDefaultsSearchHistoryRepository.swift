//
//  UserDefaultsSearchHistoryRepository.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Guarda el historial de búsquedas en UserDefaults.
/// Para una lista corta de textos es suficiente y sobrevive a que se cierre la app.
///
/// Swift 6 no marca `UserDefaults` como `Sendable`, pero Apple documenta que es seguro
/// usarlo desde varios hilos; por eso usamos `@unchecked Sendable`. La clase no tiene
/// estado propio que pueda cambiar (sus propiedades son `let`).
final class UserDefaultsSearchHistoryRepository: SearchHistoryRepository, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let storageKey: String

    init(userDefaults: UserDefaults = .standard, storageKey: String = "search_history_terms") {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    /// Lee la lista guardada; si todavía no hay nada, regresa una lista vacía.
    func loadTerms() -> [String] {
        userDefaults.stringArray(forKey: storageKey) ?? []
    }

    /// Sobrescribe la lista completa.
    func saveTerms(_ terms: [String]) {
        userDefaults.set(terms, forKey: storageKey)
    }
}
