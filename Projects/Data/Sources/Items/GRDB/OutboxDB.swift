import Foundation
internal import GRDB
import Sync

struct OutboxDB: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "outbox"

    let id: String
    let payload: Data
    let status: OutboxStatus
    let createdAt: Date
}

extension OutboxDB {
    init(payload: SyncPayload) throws {
        self.init(
            id: payload.id.uuidString,
            payload: try Self.encoder.encode(SyncEnvelope.payload(payload)),
            status: .pending,
            createdAt: payload.version.physicalTime
        )
    }

    func toPayload() throws -> SyncPayload {
        let envelope = try Self.decoder.decode(SyncEnvelope.self, from: payload)

        guard case .payload(let payload) = envelope else {
            throw OutboxDBMappingError.invalidEnvelope
        }

        return payload
    }
}

private extension OutboxDB {
    // MARK: - Static properties

    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
}
