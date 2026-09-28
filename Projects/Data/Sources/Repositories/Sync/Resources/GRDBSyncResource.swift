import Foundation
internal import GRDB
import Sync

struct GRDBSyncResource<Record: GRDBSyncRecord>: SyncResource {
    // MARK: - Private properties

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let dbPool: any DatabaseWriter
    private let versionGenerator = SyncVersionGenerator()

    // MARK: - Internal properties

    var dataType: SyncDataType { Record.syncDataType }

    // MARK: - Lifecycle

    init(dbPool: any DatabaseWriter) {
        self.dbPool = dbPool
    }

    // MARK: - Internal methods

    func create(_ value: Record.Value) async throws {
        try await dbPool.write { db in
            try Record.from(plain: value).insert(db)
            try enqueue(recordID: value.id, data: encoder.encode(value), in: db)
        }
    }

    func update(_ value: Record.Value) async throws {
        try await dbPool.write { db in
            try Record.from(plain: value).upsert(db)
            try enqueue(recordID: value.id, data: encoder.encode(value), in: db)
        }
    }

    func delete(recordID: UUID) async throws {
        try await dbPool.write { db in
            try Record.deleteOne(db, key: recordID.uuidString)
            try enqueue(recordID: recordID, data: Data(), isDeleted: true, in: db)
        }
    }

    func deleteAll() async throws {
        try await dbPool.write { db in
            for record in try Record.fetchAll(db) {
                try enqueue(recordID: record.toPlain().id, data: Data(), isDeleted: true, in: db)
            }

            try Record.deleteAll(db)
        }
    }

    func applyMatching(_ payload: SyncPayload) async throws -> Bool {
        try await dbPool.write { db in
            let metadata = try metadataRequest(recordID: payload.recordID).fetchOne(db)

            if let metadata, try metadata.version >= payload.version {
                return false
            }

            if payload.isDeleted {
                try Record.deleteOne(db, key: payload.recordID.uuidString)
            }
            else {
                let value = try decoder.decode(Record.Value.self, from: payload.data)

                guard value.id == payload.recordID else {
                    return false
                }

                try Record.from(plain: value).upsert(db)
            }

            try SyncMetadataDB(payload: payload).upsert(db)

            return true
        }
    }

    // MARK: - Private methods

    private func metadataRequest(recordID: UUID) -> QueryInterfaceRequest<SyncMetadataDB> {
        SyncMetadataDB
            .filter(Column("dataType") == dataType.rawValue && Column("recordID") == recordID.uuidString)
    }

    private func enqueue(recordID: UUID, data: Data, isDeleted: Bool = false, in db: Database) throws {
        let payload = try SyncPayload(
            recordID: recordID,
            dataType: dataType,
            version: versionGenerator.next(in: db),
            isDeleted: isDeleted,
            data: data
        )
        try SyncMetadataDB(payload: payload).upsert(db)
        try OutboxDB(payload: payload).insert(db)
    }
}
