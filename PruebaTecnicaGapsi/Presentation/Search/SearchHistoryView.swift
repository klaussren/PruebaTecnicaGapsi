//
//  SearchHistoryView.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import SwiftUI

/// Lista de búsquedas previas. Al tocar una se vuelve a buscar.
/// Si todavía no hay historial, muestra una pantalla de bienvenida con el logo.
/// No conoce al ViewModel: solo recibe los datos y avisa con closures qué tocó el usuario.
struct SearchHistoryView: View {
    let terms: [String]
    let onSelect: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        if terms.isEmpty {
            welcome
        } else {
            historyList
        }
    }

    private var welcome: some View {
        VStack(spacing: 16) {
            Image("GapsiLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .accessibilityHidden(true)

            Text("¡Bienvenido!")
                .font(.title2.bold())

            Text("Escribe lo que buscas, por ejemplo \"nintendo\", \"sony\" o \"computer\". Tus búsquedas aparecerán aquí.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private var historyList: some View {
        List {
            Section {
                ForEach(terms, id: \.self) { term in
                    Button {
                        onSelect(term)
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.accentColor)
                            Text(term)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Búsquedas recientes")
                    Spacer()
                    Button("Borrar", action: onClear)
                        .font(.footnote.weight(.semibold))
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
