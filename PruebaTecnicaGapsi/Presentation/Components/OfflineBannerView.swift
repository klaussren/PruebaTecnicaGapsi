//
//  OfflineBannerView.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import SwiftUI

/// Franja roja que aparece debajo de la barra de búsqueda cuando no hay internet.
struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text("Sin conexión a internet")
                .font(.footnote.weight(.semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.red)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    OfflineBannerView()
}
#endif
