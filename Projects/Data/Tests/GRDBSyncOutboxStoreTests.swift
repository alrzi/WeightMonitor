import Foundation
internal import GRDB
import Sync
import Testing
@testable import Data

@Suite
struct GRDBSyncOutboxStoreTests {
    @Test
    func test_recoversInterruptedDeliveriesAndReturnsRetryablePayloadsInFIFOOrder() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncOutboxStore(dbPool: dbPool)
        let firstPayload = makePayload(recordID: UUID(), createdAt: 1_000)
        let secondPayload = makePayload(recordID: UUID(), createdAt: 2_000)
        let interruptedPayload = makePayload(recordID: UUID(), createdAt: 3_000)

        try await dbPool.write { db in
            try OutboxDB(payload: firstPayload).insert(db)
            try OutboxDB(payload: secondPayload).insert(db)
            try OutboxDB(payload: interruptedPayload).insert(db)
            _ = try OutboxDB.filter(Column("id") == secondPayload.id.uuidString)
                .updateAll(db, [Column("status").set(to: OutboxStatus.failed.rawValue)])
            _ = try OutboxDB.filter(Column("id") == interruptedPayload.id.uuidString)
                .updateAll(db, [Column("status").set(to: OutboxStatus.sending.rawValue)])
        }

        // WHEN
        try await store.recoverInterruptedDeliveries()
        let payloads = try await store.pendingPayloads()

        // THEN
        #expect(payloads.map(\.id) == [firstPayload.id, secondPayload.id, interruptedPayload.id])
    }

    @Test("Отправленное изменение остаётся в очереди до подтверждения другим устройством, а после подтверждения не отправляется повторно")
    func test_marksPayloadSyncedOnlyWhenAcknowledged() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncOutboxStore(dbPool: dbPool)
        let payload = makePayload(recordID: UUID())
        try await dbPool.write { db in
            try OutboxDB(payload: payload).insert(db)
        }

        // WHEN
        try await store.markSending(payloadID: payload.id)
        try await store.markAwaitingAcknowledgement(payloadID: payload.id)
        let awaitingAcknowledgement = try await status(of: payload.id, in: dbPool)
        try await store.markSynced(payloadID: payload.id)

        // THEN
        #expect(awaitingAcknowledgement == .awaitingAcknowledgement)
        #expect(try await status(of: payload.id, in: dbPool) == .synced)
    }

    private func makeDatabasePool() throws -> DatabaseQueue {
        let dbPool = try DatabaseQueue()
        try GRDBPoolProvider.migrator.migrate(dbPool)
        return dbPool
    }

    private func makePayload(recordID: UUID, createdAt: TimeInterval = 1_000) -> SyncPayload {
        SyncPayload(
            recordID: recordID,
            dataType: SyncDataType(rawValue: "weight"),
            version: SyncVersion(
                physicalTime: Date(timeIntervalSince1970: createdAt),
                logicalCounter: 1,
                deviceID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
            ),
            isDeleted: false,
            data: Data()
        )
    }

    private func status(of payloadID: UUID, in dbPool: any DatabaseWriter) async throws -> OutboxStatus? {
        try await dbPool.read { db in
            try OutboxDB.fetchOne(db, key: payloadID.uuidString)?.status
        }
    }
}
