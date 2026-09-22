//
//  MockSearchHistoryRepository.swift
//  PruebaTecnicaGapsiTests
//
//  Created by Klauss Sheffield Rendon Muñoz on 22/09/26.
//

import Foundation
@testable import PruebaTecnicaGapsi

/// Historial en memoria: guarda la lista en una variable en lugar de UserDefaults.
final class MockSearchHistoryRepository: SearchHistoryRepository, @unchecked Sendable {
    private(set) var storedTerms: [String]
    private(set) var saveCallCount = 0

    init(storedTerms: [String] = []) {
        self.storedTerms = storedTerms
    }

    func loadTerms() -> [String] {
        storedTerms
    }

    func saveTerms(_ terms: [String]) {
        saveCallCount += 1
        storedTerms = terms
    }
}
