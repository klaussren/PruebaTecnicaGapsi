//
//  MockConnectivityChecker.swift
//  PruebaTecnicaGapsiTests
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation
@testable import PruebaTecnicaGapsi

/// Conexión falsa: con `isConnected` decidimos si la prueba corre "con" o "sin" internet.
struct MockConnectivityChecker: ConnectivityChecker {
    var isConnected = true
}
