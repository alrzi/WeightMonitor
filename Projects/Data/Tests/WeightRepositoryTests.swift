import Domain
import Foundation
internal import GRDB
import Sync
import Testing
@testable import Data

@Suite
struct WeightRepositoryTests {
    private let weightDataType = SyncDataType(rawValue: "weight")

    @Test
    func test_createEnqueuesPendingSyncPayload() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let repository = WeightRepository(
            dbPool: dbPool,
            syncResource: GRDBSyncResource<WeightDB>(
                dbPool: dbPool,
                dataType: weightDataType
            )
        )
        let weight = Weight(
            createdAt: Date(timeIntervalSince1970: 1_000),
            mass: 75
        )

        // WHEN
        try await repository.create(weight: weight)

        // THEN
        let result = try await dbPool.read { db in
            (
                try WeightDB.fetchOne(db, key: weight.id.uuidString),
                try SyncMetadataDB.fetchOne(
                    db,
                    key: [
                        "dataType": weightDataType.rawValue,
                        "recordID": weight.id.uuidString,
                    ]
                ),
                try OutboxDB.fetchAll(db)
            )
        }

        #expect(try result.0?.toPlain() == weight)
        #expect(result.1?.isDeleted == false)
        #expect(result.2.count == 1)
        #expect(result.2.first?.status == .pending)
    }

    // MARK: - Private methods

    private func makeDatabasePool() throws -> DatabaseQueue {
        let dbPool = try DatabaseQueue()
        try GRDBPoolProvider.migrator.migrate(dbPool)
        return dbPool
    }
}
