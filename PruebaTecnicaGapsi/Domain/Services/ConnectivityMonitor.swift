//
//  ConnectivityMonitor.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation

/// Lo único que necesita saber un caso de uso: si en este momento hay internet.
protocol ConnectivityChecker: Sendable {
    var isConnected: Bool { get }
}

/// Además de preguntar, permite escuchar los cambios de conexión.
/// Lo usa la pantalla para mostrar el aviso de "sin conexión" en cuanto se pierde el internet.
protocol ConnectivityMonitor: ConnectivityChecker {
    /// Emite `true`/`false` cada vez que cambia la conexión (y el valor actual al suscribirse).
    func statusUpdates() -> AsyncStream<Bool>
}
