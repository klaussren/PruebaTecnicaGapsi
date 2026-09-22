//
//  ProductRowView.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import SwiftUI

/// Una fila de la lista: imagen a la izquierda, título y precio a la derecha.
struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
                .frame(width: 80, height: 80)
                .padding(6)
                // Fondo blanco fijo: las fotos de Walmart vienen sobre blanco (se ve bien en modo oscuro).
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(3)

                Text(formattedPrice)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.accentColor)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    /// Imagen asíncrona con indicador de carga e ícono genérico si falla.
    private var thumbnail: some View {
        AsyncImage(url: product.thumbnailURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.gray)
            default:
                ProgressView()
            }
        }
    }

    /// Precio con formato de moneda (ej. "$69.99"), o "Desde $10.00" si es el mínimo de un rango.
    private var formattedPrice: String {
        guard let price = product.price else {
            return String(localized: "Precio no disponible")
        }
        let amount = price.formatted(.currency(code: product.currencyCode))
        return product.isStartingPrice ? String(localized: "Desde \(amount)") : amount
    }
}
