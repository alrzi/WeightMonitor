import Foundation
internal import GRDB
import Sync
import Testing
@testable import Data

@Suite
struct GRDBSyncOutboxStoreTests {
    private let retryPolicy = SyncRetryPolicy(
        maximumAttemptCount: 3,
        acknowledgementTimeout: 60
    )

    @Test
    func test_returnsAllUnsyncedPayloadsAsRetryableInFIFOOrder() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncOutboxStore(dbPool: dbPool, retryPolicy: retryPolicy)
        let firstPayload = makePayload(recordID: UUID(), createdAt: 1_000)
        let secondPayload = makePayload(recordID: UUID(), createdAt: 2_000)
        let interruptedPayload = makePayload(recordID: UUID(), createdAt: 3_000)
        let unacknowledgedPayload = makePayload(recordID: UUID(), createdAt: 4_000)
        let syncedPayload = makePayload(recordID: UUID(), createdAt: 5_000)

        try await dbPool.write { db in
            try OutboxDB(payload: firstPayload).insert(db)
            try OutboxDB(payload: secondPayload).insert(db)
            try OutboxDB(payload: interruptedPayload).insert(db)
            try OutboxDB(payload: unacknowledgedPayload).insert(db)
            try OutboxDB(payload: syncedPayload).insert(db)
            _ = try OutboxDB.filter(Column("id") == secondPayload.id.uuidString)
                .updateAll(db, [Column("status").set(to: OutboxStatus.failed.rawValue)])
            _ = try OutboxDB.filter(Column("id") == interruptedPayload.id.uuidString)
                .updateAll(db, [Column("status").set(to: OutboxStatus.sending.rawValue)])
            _ = try OutboxDB.filter(Column("id") == unacknowledgedPayload.id.uuidString)
                .updateAll(db, [Column("status").set(to: OutboxStatus.awaitingAcknowledgement.rawValue)])
            _ = try OutboxDB.filter(Column("id") == syncedPayload.id.uuidString)
                .updateAll(db, [Column("status").set(to: OutboxStatus.synced.rawValue)])
        }

        // WHEN
        let payloads = try await store.retryablePayloads()

        // THEN
        #expect(payloads.map(\.id) == [firstPayload.id, secondPayload.id, interruptedPayload.id, unacknowledgedPayload.id])
    }

    @Test("Отправленное изменение остаётся в очереди до подтверждения другим устройством, а после подтверждения не отправляется повторно")
    func test_marksPayloadSyncedOnlyWhenAcknowledged() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let store = GRDBSyncOutboxStore(dbPool: dbPool, retryPolicy: retryPolicy)
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

    @Test("Не повторяет payload до истечения времени ожидания acknowledgement")
    func test_doesNotImmediatelyRetryPayloadAwaitingAcknowledgement() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let now = Date(timeIntervalSince1970: 10_000)
        let payload = makePayload(recordID: UUID())
        let store = GRDBSyncOutboxStore(
            dbPool: dbPool,
            retryPolicy: retryPolicy,
            now: { now }
        )
        try await dbPool.write { db in
            try OutboxDB(payload: payload).insert(db)
        }

        // WHEN
        try await store.markSending(payloadID: payload.id)
        try await store.markAwaitingAcknowledgement(payloadID: payload.id)

        // THEN
        #expect(try await store.retryablePayloads().isEmpty)

        // WHEN
        let storeAfterTimeout = GRDBSyncOutboxStore(
            dbPool: dbPool,
            retryPolicy: retryPolicy,
            now: { now.addingTimeInterval(retryPolicy.acknowledgementTimeout + 1) }
        )

        // THEN
        #expect(try await storeAfterTimeout.retryablePayloads().map(\.id) == [payload.id])
    }

    @Test("Прекращает автоматические повторы после максимального количества попыток")
    func test_stopsRetryingPayloadAfterMaximumAttemptCount() async throws {
        // GIVEN
        let dbPool = try makeDatabasePool()
        let payload = makePayload(recordID: UUID())
        let store = GRDBSyncOutboxStore(dbPool: dbPool, retryPolicy: retryPolicy)
        try await dbPool.write { db in
            try OutboxDB(payload: payload).insert(db)
        }

        // WHEN
        for _ in 0..<retryPolicy.maximumAttemptCount {
            try await store.markSending(payloadID: payload.id)
            try await store.markFailed(payloadID: payload.id)
        }

        // THEN
        #expect(try await store.retryablePayloads().isEmpty)
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
