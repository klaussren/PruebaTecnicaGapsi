//
//  SearchView.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import SwiftUI

/// Pantalla principal: logo arriba, barra de búsqueda y, abajo, lo que toque según el estado
/// (historial, cargando, resultados, sin resultados o error).
struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    /// Recibimos el ViewModel ya armado desde fuera (inyección de dependencias).
    /// Se usa @autoclosure para que SwiftUI lo cree una sola vez aunque la vista se redibuje.
    init(viewModel: @autoclosure @escaping () -> SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                // El aviso de "sin conexión" se acomoda arriba del contenido sin taparlo.
                .safeAreaInset(edge: .top, spacing: 0) {
                    if viewModel.isOffline {
                        OfflineBannerView()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut, value: viewModel.isOffline)
                .navigationTitle("Productos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // En lugar del título en texto mostramos el logo de Gapsi.
                    ToolbarItem(placement: .principal) {
                        Image("GapsiLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .accessibilityLabel(Text(verbatim: "Gapsi"))
                    }
                }
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar productos (ej. nintendo)"
                )
                .onSubmit(of: .search) {
                    viewModel.submitSearch()
                }
        }
        .task {
            viewModel.loadSearchHistory()
            // Se queda escuchando la conexión mientras la pantalla exista.
            await viewModel.observeConnectivity()
        }
    }

    /// Decide qué mostrar dependiendo del estado del ViewModel.
    /// Nota sobre idiomas: los textos escritos directo en `Text`, `Button`, etc. se traducen solos;
    /// los que se mandan como `String` a otra vista usan `String(localized:)` para que también se traduzcan.
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            SearchHistoryView(
                terms: viewModel.searchHistory,
                onSelect: viewModel.selectHistoryTerm,
                onClear: viewModel.clearSearchHistory
            )

        case .loading:
            ProgressView("Buscando productos...")

        case .empty:
            StateMessageView(
                systemImage: "magnifyingglass",
                title: String(localized: "Sin resultados"),
                message: String(localized: "No encontramos productos para \"\(viewModel.currentKeyword)\". Prueba con otra palabra en inglés o una marca.")
            )

        case .failure(let message):
            StateMessageView(
                systemImage: viewModel.isOffline ? "wifi.slash" : "exclamationmark.triangle",
                title: viewModel.isOffline ? String(localized: "Sin conexión") : String(localized: "Algo salió mal"),
                message: message,
                actionTitle: String(localized: "Reintentar"),
                action: viewModel.retry
            )

        case .loaded:
            productList
        }
    }

    /// Lista de productos con scroll infinito: cada fila avisa al ViewModel cuando aparece
    /// y al final se muestra un indicador de carga, un botón para reintentar o el fin de la lista.
    private var productList: some View {
        List {
            Section {
                ForEach(viewModel.products) { product in
                    ProductRowView(product: product)
                        .onAppear {
                            viewModel.loadNextPageIfNeeded(currentProduct: product)
                        }
                }
            } header: {
                Text("Resultados para \"\(viewModel.currentKeyword)\"")
            } footer: {
                listFooter
            }
        }
        .listStyle(.insetGrouped)
        // Si el usuario empieza a arrastrar la lista, bajamos el teclado.
        .scrollDismissesKeyboard(.immediately)
    }

    /// Lo que va debajo del último producto.
    @ViewBuilder
    private var listFooter: some View {
        Group {
            if viewModel.isLoadingNextPage {
                ProgressView()
            } else if let errorMessage = viewModel.nextPageErrorMessage {
                VStack(spacing: 8) {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                    Button("Reintentar", action: viewModel.loadNextPage)
                        .font(.subheadline.weight(.semibold))
                }
            } else if !viewModel.hasMorePages {
                Text("No hay más resultados")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
