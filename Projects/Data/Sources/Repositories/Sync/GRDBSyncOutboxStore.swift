import Foundation
internal import GRDB
import Sync

struct GRDBSyncOutboxStore: SyncOutboxStore {
    private let dbPool: any DatabaseWriter
    private let retryPolicy: SyncRetryPolicy
    private let now: @Sendable () -> Date
    private let observationQueue = DispatchQueue(label: "com.alrzi.queue.sync.outbox", qos: .userInitiated)

    init(
        dbPool: any DatabaseWriter,
        retryPolicy: SyncRetryPolicy,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.dbPool = dbPool
        self.retryPolicy = retryPolicy
        self.now = now
    }

    func observePayloadCount() async -> AsyncThrowingStream<Int, any Error> {
        AsyncThrowingStream { [dbPool, observationQueue] continuation in
            let observation = ValueObservation.tracking { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM outbox") ?? 0
            }
            .removeDuplicates()

            let cancellable = observation.start(
                in: dbPool,
                scheduling: .async(onQueue: observationQueue),
                onError: { continuation.finish(throwing: $0) },
                onChange: { continuation.yield($0) }
            )

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    func retryablePayloads() async throws -> [SyncPayload] {
        let acknowledgementDeadline = now().addingTimeInterval(-retryPolicy.acknowledgementTimeout)

        return try await dbPool.read { db in
            try OutboxDB
                .retryable(
                    acknowledgementDeadline: acknowledgementDeadline,
                    maximumAttemptCount: retryPolicy.maximumAttemptCount
                )
                .order(OutboxDB.Columns.createdAt.asc)
                .fetchAll(db)
                .map { try $0.toPayload() }
        }
    }

    func markSending(payloadID: UUID) async throws {
        try await dbPool.write { [now] db in
            try OutboxDB.markSending(
                payloadID: payloadID,
                at: now(),
                in: db
            )
        }
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
        try await dbPool.write { db in
            try OutboxDB.updateStatus(
                status,
                payloadID: payloadID,
                in: db
            )
        }
    }
}
