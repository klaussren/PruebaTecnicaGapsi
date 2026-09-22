//
//  SearchHistoryUseCasesTests.swift
//  PruebaTecnicaGapsiTests
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import XCTest
@testable import PruebaTecnicaGapsi

/// Pruebas de los casos de uso para leer y borrar el historial.
final class SearchHistoryUseCasesTests: XCTestCase {

    /// Regresa las búsquedas guardadas en el mismo orden.
    func test_getSearchHistory_returnsStoredTerms() {
        let repository = MockSearchHistoryRepository(storedTerms: ["nintendo", "sony"])
        let sut = DefaultGetSearchHistoryUseCase(repository: repository)

        XCTAssertEqual(sut.execute(), ["nintendo", "sony"])
    }

    /// Si nunca se ha buscado nada, la lista viene vacía.
    func test_getSearchHistory_withoutSavedTerms_returnsEmptyList() {
        let sut = DefaultGetSearchHistoryUseCase(repository: MockSearchHistoryRepository())

        XCTAssertEqual(sut.execute(), [])
    }

    /// Borrar deja el historial vacío.
    func test_clearSearchHistory_removesAllTerms() {
        let repository = MockSearchHistoryRepository(storedTerms: ["nintendo", "sony"])
        let sut = DefaultClearSearchHistoryUseCase(repository: repository)

        sut.execute()

        XCTAssertEqual(repository.storedTerms, [])
    }

    /// Prueba de integración ligera: el historial se mantiene "después de reiniciar"
    /// usando UserDefaults real (en un suite aparte para no ensuciar el de la app).
    func test_history_persistsBetweenRepositoryInstances() throws {
        let suiteName = "SearchHistoryUseCasesTests"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let save = DefaultSaveSearchTermUseCase(repository: UserDefaultsSearchHistoryRepository(userDefaults: userDefaults))
        save.execute(term: "sony")
        save.execute(term: "nintendo")

        // Una instancia nueva simula que la app se cerró y se volvió a abrir.
        let get = DefaultGetSearchHistoryUseCase(repository: UserDefaultsSearchHistoryRepository(userDefaults: userDefaults))

        XCTAssertEqual(get.execute(), ["nintendo", "sony"])
    }
}
