//
//  SearchViewModel.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Combine
import Foundation

/// ViewModel de la pantalla de búsqueda.
/// Guarda el estado de la pantalla (resultados, historial, cargando, errores)
/// y le pide todo a los casos de uso; no sabe nada de URLs, JSON ni UserDefaults.
/// Vive en el MainActor porque todo lo que publica lo dibuja SwiftUI.
@MainActor
final class SearchViewModel: ObservableObject {

    /// Lo que la pantalla principal debe mostrar en cada momento.
    enum State: Equatable {
        /// Todavía no se busca nada: se muestra el historial.
        case idle
        /// Cargando la primera página de una búsqueda nueva.
        case loading
        /// Hay productos en pantalla.
        case loaded
        /// La búsqueda terminó bien pero no trajo nada.
        case empty
        /// Algo falló al cargar la primera página.
        case failure(message: String)
    }

    /// Texto de la barra de búsqueda. Si el usuario lo borra, regresamos al historial.
    @Published var searchText = "" {
        didSet {
            if searchText.isEmpty && oldValue.isEmpty == false {
                resetResults()
            }
        }
    }
    @Published private(set) var state: State = .idle
    @Published private(set) var products: [Product] = []
    @Published private(set) var searchHistory: [String] = []
    @Published private(set) var isLoadingNextPage = false
    /// Error al cargar las páginas siguientes. Se muestra al final de la lista
    /// sin borrar lo que ya se había cargado.
    @Published private(set) var nextPageErrorMessage: String?
    /// `true` cuando el teléfono se queda sin internet; la vista muestra un aviso arriba.
    @Published private(set) var isOffline = false

    /// La palabra de la búsqueda que se está mostrando (puede ser distinta a `searchText`
    /// si el usuario ya empezó a escribir otra cosa sin darle buscar).
    private(set) var currentKeyword = ""

    /// Cuántos productos antes del final empezamos a pedir la siguiente página,
    /// para que al usuario casi no le toque ver el indicador de carga.
    private let prefetchThreshold = 5

    /// Indica si quedan páginas por cargar; la vista lo usa para mostrar "No hay más resultados".
    @Published private(set) var hasMorePages = false

    private var currentPage = 0
    /// Walmart a veces repite productos entre páginas; con esto evitamos duplicados en la lista.
    private var loadedProductIDs = Set<String>()
    private var searchTask: Task<Void, Never>?
    private var nextPageTask: Task<Void, Never>?

    private let searchProductsUseCase: SearchProductsUseCase
    private let getSearchHistoryUseCase: GetSearchHistoryUseCase
    private let saveSearchTermUseCase: SaveSearchTermUseCase
    private let clearSearchHistoryUseCase: ClearSearchHistoryUseCase
    private let connectivityMonitor: ConnectivityMonitor

    init(
        searchProductsUseCase: SearchProductsUseCase,
        getSearchHistoryUseCase: GetSearchHistoryUseCase,
        saveSearchTermUseCase: SaveSearchTermUseCase,
        clearSearchHistoryUseCase: ClearSearchHistoryUseCase,
        connectivityMonitor: ConnectivityMonitor
    ) {
        self.searchProductsUseCase = searchProductsUseCase
        self.getSearchHistoryUseCase = getSearchHistoryUseCase
        self.saveSearchTermUseCase = saveSearchTermUseCase
        self.clearSearchHistoryUseCase = clearSearchHistoryUseCase
        self.connectivityMonitor = connectivityMonitor
    }

    // MARK: - Conexión

    /// Escucha los cambios de conexión. Se llama desde `.task`, que lo cancela al salir de la pantalla.
    func observeConnectivity() async {
        for await isConnected in connectivityMonitor.statusUpdates() {
            let recoveredConnection = isOffline && isConnected
            isOffline = !isConnected

            if recoveredConnection {
                retryAfterReconnection()
            }
        }
    }

    /// Si algo falló mientras no había internet, lo reintentamos solos al volver la conexión,
    /// para que el usuario no tenga que tocar "Reintentar".
    private func retryAfterReconnection() {
        if case .failure = state {
            retry()
        } else if nextPageErrorMessage != nil {
            loadNextPage()
        }
    }

    // MARK: - Historial

    /// Carga el historial guardado. Se llama al abrir la pantalla.
    func loadSearchHistory() {
        searchHistory = getSearchHistoryUseCase.execute()
    }

    /// Borra todas las búsquedas previas.
    func clearSearchHistory() {
        clearSearchHistoryUseCase.execute()
        searchHistory = []
    }

    // MARK: - Búsqueda

    /// El usuario le dio "Buscar" en el teclado.
    func submitSearch() {
        search(searchText)
    }

    /// El usuario tocó una búsqueda del historial: la ponemos en la barra y buscamos.
    func selectHistoryTerm(_ term: String) {
        searchText = term
        search(term)
    }

    /// Vuelve a intentar la búsqueda actual cuando falló la primera página.
    func retry() {
        search(currentKeyword)
    }

    /// Inicia una búsqueda nueva desde la página 1 y cancela la anterior si seguía en curso.
    func search(_ term: String) {
        let keyword = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return }

        searchHistory = saveSearchTermUseCase.execute(term: keyword)

        cancelRunningTasks()
        clearPaginationState()
        currentKeyword = keyword
        state = .loading

        searchTask = Task { [weak self] in
            await self?.loadFirstPage(for: keyword)
        }
    }

    /// Se llama cada vez que aparece un producto en pantalla.
    /// Si ya estamos cerca del final de la lista, pedimos la siguiente página.
    func loadNextPageIfNeeded(currentProduct product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }),
              index >= products.count - prefetchThreshold else {
            return
        }
        loadNextPage()
    }

    /// Pide la siguiente página, siempre y cuando haya más y no estemos ya cargando una.
    /// También se usa desde el botón "Reintentar" del final de la lista.
    func loadNextPage() {
        guard state == .loaded, hasMorePages, !isLoadingNextPage else { return }

        isLoadingNextPage = true
        nextPageErrorMessage = nil
        let keyword = currentKeyword
        let nextPage = currentPage + 1

        nextPageTask = Task { [weak self] in
            await self?.fetchNextPage(keyword: keyword, page: nextPage)
        }
    }

    // MARK: - Privados

    /// Trae la primera página y decide qué mostrar: lista, vacío o error.
    private func loadFirstPage(for keyword: String) async {
        do {
            let page = try await searchProductsUseCase.execute(keyword: keyword, page: 1)
            guard !Task.isCancelled else { return }

            append(page)
            state = products.isEmpty ? .empty : .loaded
        } catch {
            // Si la tarea se canceló es porque el usuario ya hizo otra búsqueda; no mostramos nada.
            guard !Task.isCancelled, !(error is CancellationError) else { return }
            state = .failure(message: Self.message(for: error))
        }
    }

    /// Trae una página adicional y la agrega al final de la lista.
    private func fetchNextPage(keyword: String, page: Int) async {
        do {
            let result = try await searchProductsUseCase.execute(keyword: keyword, page: page)
            // Si mientras cargaba el usuario cambió de búsqueda, esta página ya no sirve.
            guard !Task.isCancelled, keyword == currentKeyword else { return }

            let addedCount = append(result)
            isLoadingNextPage = false

            // Si todos los productos de la página eran repetidos no aparece ninguna fila nueva
            // y el scroll ya no dispararía la carga; por eso pedimos la siguiente de una vez.
            if addedCount == 0 {
                loadNextPage()
            }
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), keyword == currentKeyword else { return }
            isLoadingNextPage = false
            nextPageErrorMessage = Self.message(for: error)
        }
    }

    /// Agrega los productos de una página quitando repetidos y actualiza la paginación.
    /// Regresa cuántos productos nuevos se agregaron.
    @discardableResult
    private func append(_ page: ProductPage) -> Int {
        let newProducts = page.products.filter { loadedProductIDs.insert($0.id).inserted }
        products.append(contentsOf: newProducts)
        currentPage = page.currentPage
        hasMorePages = page.hasMorePages
        return newProducts.count
    }

    /// Regresa la pantalla al estado inicial (historial) cuando se borra el texto.
    private func resetResults() {
        cancelRunningTasks()
        clearPaginationState()
        currentKeyword = ""
        state = .idle
    }

    private func cancelRunningTasks() {
        searchTask?.cancel()
        nextPageTask?.cancel()
    }

    private func clearPaginationState() {
        products = []
        loadedProductIDs = []
        currentPage = 0
        hasMorePages = false
        isLoadingNextPage = false
        nextPageErrorMessage = nil
    }

    /// Convierte cualquier error en un mensaje entendible para el usuario.
    private static func message(for error: Error) -> String {
        (error as? DomainError)?.userMessage ?? String(localized: "Ocurrió un error inesperado. Intenta de nuevo.")
    }
}
