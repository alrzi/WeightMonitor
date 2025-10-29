//
//  WeigthRepository.swift
//  WeigthMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import GRDB
import WeigthMonitorDomain
internal import Combine

struct WeigthRepository: WeigthRepositoryProtocol {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }

    func observe() -> AsyncThrowingStream<[Weight], any Error> {
        AsyncThrowingStream { continuation in
            let observation = ValueObservation.tracking { db in
                try Self.fetchAll(db: db)
            }

            let cancellable = observation.start(
                in: dbPool,
                onError: { continuation.finish(throwing: $0) },
                onChange: { continuation.yield($0) }
            )

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    func create(weight: Weight) async throws {
        try await dbPool.write { db in
            try WeightDB
                .from(plain: weight)
                .insert(db)
        }
    }

    func readAll() async throws -> [Weight] {
        try await dbPool.read { db in
            try Self.fetchAll(db: db)
        }
    }

    func update(weight: Weight) async throws {
        try await dbPool.write { db in
            try WeightDB.from(plain: weight)
                .upsert(db)
        }
    }

    func delete(weight: Weight) async throws {
        _ = try await dbPool.write { db in
            try WeightDB.from(plain: weight)
                .delete(db)
        }
    }

    func deleteAll() async throws {
        _ = try await dbPool.write { db in
            try WeightDB.deleteAll(db)
        }
    }

    func count() async throws -> Int {
        try await dbPool.read { db in
            try WeightDB.fetchCount(db)
        }
    }
}

extension WeigthRepository {
    static func fetchAll(db: Database) throws -> [Weight] {
        try WeightDB
            .order(\.createdAt.desc)
            .fetchAll(db)
            .map { $0.toPlain() }
    }
}

