//
//  StateMessageView.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import SwiftUI

/// Vista genérica para mensajes de pantalla completa (vacío, error, bienvenida).
/// Hace algo parecido a `ContentUnavailableView`, que no existe en iOS 16.
struct StateMessageView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundColor(.accentColor)

            Text(title)
                .font(.title3.bold())

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // El botón solo aparece si nos pasaron título y acción (por ejemplo "Reintentar").
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 4)
            }
        }
        .padding(32)
    }
}
