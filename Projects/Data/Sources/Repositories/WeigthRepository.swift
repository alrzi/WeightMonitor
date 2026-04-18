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
    private let dbPool: any DatabaseWriter

    init(dbPool: any DatabaseWriter) {
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

    func paginate(after cursor: WeightCursor?, limit: Int) async throws -> [Weight] {
        let limit = max(1, limit)

        return try await dbPool.read { db in
            let request: QueryInterfaceRequest<WeightDB>

            if let cursor {
                let createdAtColumn = WeightDB.Columns.createdAt
                let idColumn = Column("id")

                let earlierCreatedAt = createdAtColumn < cursor.createdAt
                let sameCreatedAtEarlierId = createdAtColumn == cursor.createdAt && idColumn < cursor.id

                request = WeightDB
                    .filter(earlierCreatedAt || sameCreatedAtEarlierId)
                    .order(createdAtColumn.desc, idColumn.desc)
                    .limit(limit)
            }
            else {
                request = WeightDB
                    .order(WeightDB.Columns.createdAt.desc, Column("id").desc)
                    .limit(limit)
            }

            let rows = try request.fetchAll(db).map { $0.toPlain() }

            return rows
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
}

private extension WeigthRepository {
    static func fetchAll(db: Database) throws -> [Weight] {
        try WeightDB
            .order(WeightDB.Columns.createdAt.desc, Column("id").desc)
            .fetchAll(db)
            .map { $0.toPlain() }
    }
}

