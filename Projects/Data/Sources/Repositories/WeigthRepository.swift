//
//  WeightRepository.swift
//  WeightMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import GRDB
import Domain
internal import Combine
import Sync

struct WeightRepository: WeightRepositoryProtocol {
    // MARK: - Private properties

    private let dbPool: any DatabaseWriter
    private let queue = DispatchQueue(label: "com.alrzi.queue.weight.monitor", qos: .userInitiated)
    private let syncResource: GRDBSyncResource<WeightDB>

    // MARK: - Lifecycle

    init(
        dbPool: any DatabaseWriter,
        syncResource: GRDBSyncResource<WeightDB>
    ) {
        self.dbPool = dbPool
        self.syncResource = syncResource
    }

    // MARK: - Internal methods

    func observe() -> AsyncThrowingStream<[Weight], any Error> {
        AsyncThrowingStream { [queue] continuation in
            let observation = ValueObservation.tracking { db in
                try Self.fetchAll(db: db)
            }

            let cancellable = observation.start(
                in: dbPool,
                scheduling: .async(onQueue: queue),
                onError: { continuation.finish(throwing: $0) },
                onChange: { continuation.yield($0) }
            )

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    func create(weight: Weight) async throws {
        try await syncResource.create(weight)
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
                let sameCreatedAtEarlierId = createdAtColumn == cursor.createdAt && idColumn < cursor.id.uuidString

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

            let rows = try request.fetchAll(db).map { try $0.toPlain() }

            return rows
        }
    }

    func update(weight: Weight) async throws {
        try await syncResource.update(weight)
    }

    func delete(weight: Weight) async throws {
        try await syncResource.delete(recordID: weight.id)
    }

    func deleteAll() async throws {
        try await syncResource.deleteAll()
    }
}

private extension WeightRepository {
    static func fetchAll(db: Database) throws -> [Weight] {
        try WeightDB
            .order(WeightDB.Columns.createdAt.desc, Column("id").desc)
            .fetchAll(db)
            .map { try $0.toPlain() }
    }
}
