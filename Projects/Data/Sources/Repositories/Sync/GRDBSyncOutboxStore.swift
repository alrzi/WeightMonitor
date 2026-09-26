import Foundation
internal import GRDB
import Sync

struct GRDBSyncOutboxStore: SyncOutboxStore {
    private let dbPool: any DatabaseWriter

    init(dbPool: any DatabaseWriter) {
        self.dbPool = dbPool
    }

    func retryablePayloads() async throws -> [SyncPayload] {
        try await dbPool.read { db in
            try OutboxDB
                .filter(Column("status") != OutboxStatus.synced.rawValue)
                .order(Column("createdAt").asc)
                .fetchAll(db)
                .map { try $0.toPayload() }
        }
    }

    func markSending(payloadID: UUID) async throws {
        try await update(status: .sending, payloadID: payloadID)
    }

    func markAwaitingAcknowledgement(payloadID: UUID) async throws {
        try await update(status: .awaitingAcknowledgement, payloadID: payloadID)
    }

    func markFailed(payloadID: UUID) async throws {
        try await update(status: .failed, payloadID: payloadID)
    }

    func markSynced(payloadID: UUID) async throws {
        try await update(status: .synced, payloadID: payloadID)
    }

    private func update(status: OutboxStatus, payloadID: UUID) async throws {
        try await update(status: status, where: Column("id") == payloadID.uuidString)
    }

    private func update(status: OutboxStatus, where filter: SQLSpecificExpressible) async throws {
        try await dbPool.write { db in
            _ = try OutboxDB.filter(filter).updateAll(db, [Column("status").set(to: status.rawValue)])
        }
    }
}
