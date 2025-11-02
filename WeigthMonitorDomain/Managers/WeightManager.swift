//
//  WeightManager.swift
//  WeigthMonitorDomain
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation

public protocol WeightManaging: Sendable {
    @MainActor
    func observe() -> AsyncMapSequence<AsyncThrowingStream<[Weight], any Error>, [Weight]>

    func create(weight: Weight) async throws
    func readAll() async throws -> [Weight]
    func paginate(after cursor: WeightCursor?, limit: Int) async throws -> [Weight]
    func update(weight: Weight) async throws
    func delete(weight: Weight) async throws
    func deleteAll() async throws
}

final class WeightManager: WeightManaging {
    private let weightRepository: WeigthRepositoryProtocol

    init(
        weightRepository: WeigthRepositoryProtocol
    ) {
        self.weightRepository = weightRepository
    }

    func observe() -> AsyncMapSequence<AsyncThrowingStream<[Weight], any Error>, [Weight]> {
        weightRepository
            .observe()
            .map { $0 }
    }

    func create(weight: Weight) async throws {
        try await weightRepository.create(weight: weight)
    }

    func readAll() async throws -> [Weight] {
        try await weightRepository.readAll()
    }

    func update(weight: Weight) async throws {
        try await weightRepository.update(weight: weight)
    }

    func delete(weight: Weight) async throws {
        try await weightRepository.delete(weight: weight)
    }

    func deleteAll() async throws {
        try await weightRepository.deleteAll()
    }

    func paginate(after cursor: WeightCursor?, limit: Int) async throws -> [Weight] {
        try await weightRepository.paginate(after: cursor, limit: limit)        
    }
}
