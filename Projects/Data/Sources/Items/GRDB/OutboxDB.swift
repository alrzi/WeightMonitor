import Foundation
internal import GRDB
import Sync

struct OutboxDB: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "outbox"

    let id: String
    let payload: Data
    let status: OutboxStatus
    let createdAt: Date
    let attemptCount: Int
    let lastAttemptAt: Date?
}

extension OutboxDB {
    static func retryable(
        acknowledgementDeadline: Date,
        maximumAttemptCount: Int
    ) -> QueryInterfaceRequest<Self> {
        let hasAttemptsRemaining =
            Columns.attemptCount < maximumAttemptCount

        let immediatelyRetryable = [
            OutboxStatus.pending.rawValue,
            OutboxStatus.failed.rawValue,
            OutboxStatus.sending.rawValue,
        ]
        .contains(Columns.status)

        let acknowledgementTimedOut =
            Columns.status == OutboxStatus.awaitingAcknowledgement.rawValue
            && (
                Columns.lastAttemptAt == nil
                    || Columns.lastAttemptAt <= acknowledgementDeadline
            )

        return filter(
            hasAttemptsRemaining
                && (immediatelyRetryable || acknowledgementTimedOut)
        )
    }

    static func markSending(
        payloadID: UUID,
        at date: Date,
        in db: Database
    ) throws {
        _ = try filter(Columns.id == payloadID.uuidString)
            .updateAll(
                db,
                [
                    Columns.status.set(to: OutboxStatus.sending.rawValue),
                    Columns.attemptCount.set(to: Columns.attemptCount + 1),
                    Columns.lastAttemptAt.set(to: date),
                ]
            )
    }

    static func updateStatus(
        _ status: OutboxStatus,
        payloadID: UUID,
        in db: Database
    ) throws {
        _ = try filter(Columns.id == payloadID.uuidString)
            .updateAll(
                db,
                [Columns.status.set(to: status.rawValue)]
            )
    }

    init(payload: SyncPayload) throws {
        self.init(
            id: payload.id.uuidString,
            payload: try Self.encoder.encode(payload),
            status: .pending,
            createdAt: payload.version.physicalTime,
            attemptCount: 0,
            lastAttemptAt: nil
        )
    }

    func toPayload() throws -> SyncPayload {
        try Self.decoder.decode(SyncPayload.self, from: payload)
    }
}

extension OutboxDB {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let status = Column(CodingKeys.status)
        static let createdAt = Column(CodingKeys.createdAt)
        static let attemptCount = Column(CodingKeys.attemptCount)
        static let lastAttemptAt = Column(CodingKeys.lastAttemptAt)
    }
}

private extension OutboxDB {
    // MARK: - Static properties

    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
}
