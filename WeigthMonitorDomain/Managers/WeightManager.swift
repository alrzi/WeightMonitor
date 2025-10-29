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
            .map { Self.updateWeightsDiff(records: $0) }
    }

    func create(weight: Weight) async throws {
        try await weightRepository.create(weight: weight)
    }

    func readAll() async throws -> [Weight] {
        let records = try await weightRepository.readAll()

        return Self.updateWeightsDiff(records: records)
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
}

private extension WeightManager {
    static func updateWeightsDiff(records: [Weight]) -> [Weight] {
        records
            .enumerated()
            .map { index, record in
                let nextRecord = index < records.count - 1 ? records[index+1] : nil

                guard let nextRecord else {
                    return record
                }

                return record.difference(with: nextRecord)
            }
    }
}
