//
//  WeigthRepositoryProtocol.swift
//  WeigthMonitorDomain
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation

public protocol WeigthRepositoryProtocol: Sendable {
    @MainActor
    func observe() -> AsyncThrowingStream<[Weight], any Error>

    func create(weight: Weight) async throws
    func readAll() async throws -> [Weight]

    func update(weight: Weight) async throws
    func delete(weight: Weight) async throws
    func deleteAll() async throws

    func count() async throws -> Int
}

