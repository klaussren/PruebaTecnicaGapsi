//
//  NWPathConnectivityMonitor.swift
//  PruebaTecnicaGapsi
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation
import Network
import os

/// Revisa el estado de la conexión usando `NWPathMonitor` de Apple.
/// Se crea una sola vez al arrancar la app y se queda escuchando en segundo plano.
///
/// Es `@unchecked Sendable` porque el estado que cambia (si hay conexión y quién está escuchando)
/// siempre se lee y escribe dentro de un candado (`OSAllocatedUnfairLock`).
final class NWPathConnectivityMonitor: ConnectivityMonitor, @unchecked Sendable {

    private struct State {
        /// Arrancamos asumiendo que sí hay internet para no mostrar el aviso
        /// por error en el instante antes de que llegue la primera lectura real.
        var isConnected = true
        var listeners: [UUID: AsyncStream<Bool>.Continuation] = [:]
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "PruebaTecnicaGapsi.ConnectivityMonitor")
    private let state = OSAllocatedUnfairLock(initialState: State())

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.update(isConnected: path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    var isConnected: Bool {
        state.withLock { $0.isConnected }
    }

    /// Cada quien que se suscribe recibe su propio stream. Cuando deja de escuchar
    /// (por ejemplo, se cierra la pantalla) lo quitamos de la lista.
    func statusUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let id = UUID()
            let currentStatus = state.withLock { state in
                state.listeners[id] = continuation
                return state.isConnected
            }
            continuation.yield(currentStatus)

            continuation.onTermination = { [weak self] _ in
                self?.state.withLock { _ = $0.listeners.removeValue(forKey: id) }
            }
        }
    }

    /// Guarda el nuevo estado y avisa a todos los que están escuchando, solo si realmente cambió.
    private func update(isConnected: Bool) {
        let listenersToNotify = state.withLock { state -> [AsyncStream<Bool>.Continuation] in
            guard state.isConnected != isConnected else { return [] }
            state.isConnected = isConnected
            return Array(state.listeners.values)
        }
        listenersToNotify.forEach { $0.yield(isConnected) }
    }
}
