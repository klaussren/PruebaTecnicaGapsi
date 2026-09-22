//
//  SearchProductsUseCaseTests.swift
//  PruebaTecnicaGapsiTests
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import XCTest
@testable import PruebaTecnicaGapsi

final class SearchProductsUseCaseTests: XCTestCase {

    /// Si todo sale bien, el caso de uso regresa tal cual la página del repositorio.
    func test_execute_withValidKeyword_returnsRepositoryPage() async throws {
        let expectedPage = ProductPage.stub(products: [.stub(id: "1"), .stub(id: "2")], currentPage: 1, totalPages: 5)
        let repository = MockProductRepository(result: .success(expectedPage))
        let sut = DefaultSearchProductsUseCase(repository: repository, connectivity: MockConnectivityChecker())

        let page = try await sut.execute(keyword: "nintendo", page: 1)

        XCTAssertEqual(page, expectedPage)
        XCTAssertEqual(repository.receivedKeyword, "nintendo")
        XCTAssertEqual(repository.receivedPage, 1)
    }

    /// Los espacios al inicio y al final no se mandan a la API.
    func test_execute_trimsWhitespacesBeforeCallingRepository() async throws {
        let repository = MockProductRepository()
        let sut = DefaultSearchProductsUseCase(repository: repository, connectivity: MockConnectivityChecker())

        _ = try await sut.execute(keyword: "   sony \n", page: 2)

        XCTAssertEqual(repository.receivedKeyword, "sony")
        XCTAssertEqual(repository.receivedPage, 2)
    }

    /// Buscar texto vacío (o solo espacios) es un error y ni siquiera se llama al repositorio.
    func test_execute_withEmptyKeyword_throwsEmptySearchTermAndDoesNotCallRepository() async {
        let repository = MockProductRepository()
        let sut = DefaultSearchProductsUseCase(repository: repository, connectivity: MockConnectivityChecker())

        await assertThrows(DomainError.emptySearchTerm) {
            _ = try await sut.execute(keyword: "    ", page: 1)
        }
        XCTAssertEqual(repository.searchCallCount, 0)
    }

    /// Las páginas empiezan en 1; pedir la 0 o negativas no tiene sentido.
    func test_execute_withPageLowerThanOne_throwsInvalidPage() async {
        let repository = MockProductRepository()
        let sut = DefaultSearchProductsUseCase(repository: repository, connectivity: MockConnectivityChecker())

        await assertThrows(DomainError.invalidPage) {
            _ = try await sut.execute(keyword: "computer", page: 0)
        }
        XCTAssertEqual(repository.searchCallCount, 0)
    }

    /// Sin internet avisamos de inmediato con `noConnection` y no se hace la petición.
    func test_execute_withoutConnection_throwsNoConnectionAndDoesNotCallRepository() async {
        let repository = MockProductRepository()
        let sut = DefaultSearchProductsUseCase(
            repository: repository,
            connectivity: MockConnectivityChecker(isConnected: false)
        )

        await assertThrows(DomainError.noConnection) {
            _ = try await sut.execute(keyword: "nintendo", page: 1)
        }
        XCTAssertEqual(repository.searchCallCount, 0)
    }

    /// Aunque no haya internet, un texto vacío sigue siendo el primer error que se reporta.
    func test_execute_withEmptyKeywordAndNoConnection_reportsEmptySearchTermFirst() async {
        let sut = DefaultSearchProductsUseCase(
            repository: MockProductRepository(),
            connectivity: MockConnectivityChecker(isConnected: false)
        )

        await assertThrows(DomainError.emptySearchTerm) {
            _ = try await sut.execute(keyword: "", page: 1)
        }
    }

    /// Si el repositorio falla, el error sube sin cambios para que la vista lo muestre.
    func test_execute_whenRepositoryFails_propagatesError() async {
        let repository = MockProductRepository(result: .failure(DomainError.noConnection))
        let sut = DefaultSearchProductsUseCase(repository: repository, connectivity: MockConnectivityChecker())

        await assertThrows(DomainError.noConnection) {
            _ = try await sut.execute(keyword: "nintendo", page: 1)
        }
    }

    /// `hasMorePages` indica si hay que seguir pidiendo páginas con el scroll.
    func test_productPage_hasMorePages_dependsOnCurrentAndTotalPages() {
        XCTAssertTrue(ProductPage.stub(currentPage: 1, totalPages: 3).hasMorePages)
        XCTAssertFalse(ProductPage.stub(currentPage: 3, totalPages: 3).hasMorePages)
        XCTAssertFalse(ProductPage.stub(currentPage: 1, totalPages: 0).hasMorePages)
    }

    // MARK: - Helpers

    /// Verifica que el bloque lance el `DomainError` esperado.
    private func assertThrows(
        _ expectedError: DomainError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ block: () async throws -> Void
    ) async {
        do {
            try await block()
            XCTFail("Se esperaba el error \(expectedError) pero no se lanzó ninguno", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? DomainError, expectedError, file: file, line: line)
        }
    }
}
