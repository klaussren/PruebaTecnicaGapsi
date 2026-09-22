//
//  PruebaTecnicaGapsiApp.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import SwiftUI

/// Punto de entrada de la app. Crea el contenedor de dependencias
/// y le pasa a la pantalla de búsqueda su ViewModel ya armado.
@main
struct PruebaTecnicaGapsiApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            SearchView(viewModel: container.makeSearchViewModel())
        }
    }
}
