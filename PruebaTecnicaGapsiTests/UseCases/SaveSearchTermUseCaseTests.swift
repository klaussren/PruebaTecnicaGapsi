//
//  SaveSearchTermUseCaseTests.swift
//  PruebaTecnicaGapsiTests
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import XCTest
@testable import PruebaTecnicaGapsi

final class SaveSearchTermUseCaseTests: XCTestCase {

    /// La búsqueda nueva se guarda al principio de la lista.
    func test_execute_insertsNewTermAtTheTop() {
        let repository = MockSearchHistoryRepository(storedTerms: ["sony", "computer"])
        let sut = DefaultSaveSearchTermUseCase(repository: repository)

        let result = sut.execute(term: "nintendo")

        XCTAssertEqual(result, ["nintendo", "sony", "computer"])
        XCTAssertEqual(repository.storedTerms, ["nintendo", "sony", "computer"])
    }

    /// Si ya existía (aunque cambien mayúsculas), no se duplica: se mueve hasta arriba.
    func test_execute_withExistingTerm_movesItToTopWithoutDuplicates() {
        let repository = MockSearchHistoryRepository(storedTerms: ["sony", "Nintendo", "computer"])
        let sut = DefaultSaveSearchTermUseCase(repository: repository)

        let result = sut.execute(term: "nintendo")

        XCTAssertEqual(result, ["nintendo", "sony", "computer"])
    }

    /// Se guardan sin espacios de más.
    func test_execute_trimsWhitespaces() {
        let repository = MockSearchHistoryRepository()
        let sut = DefaultSaveSearchTermUseCase(repository: repository)

        let result = sut.execute(term: "  xbox  ")

        XCTAssertEqual(result, ["xbox"])
    }

    /// Un texto vacío no se guarda y el historial queda igual.
    func test_execute_withEmptyTerm_doesNotSave() {
        let repository = MockSearchHistoryRepository(storedTerms: ["sony"])
        let sut = DefaultSaveSearchTermUseCase(repository: repository)

        let result = sut.execute(term: "   ")

        XCTAssertEqual(result, ["sony"])
        XCTAssertEqual(repository.saveCallCount, 0)
    }

    /// Al pasar del límite se eliminan las búsquedas más viejas.
    func test_execute_whenExceedingLimit_dropsOldestTerms() {
        let repository = MockSearchHistoryRepository(storedTerms: ["c", "b", "a"])
        let sut = DefaultSaveSearchTermUseCase(repository: repository, maxTerms: 3)

        let result = sut.execute(term: "d")

        XCTAssertEqual(result, ["d", "c", "b"])
        XCTAssertEqual(repository.storedTerms.count, 3)
    }
}
