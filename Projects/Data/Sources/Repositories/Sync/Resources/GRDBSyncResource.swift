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

    let dataType: SyncDataType

    // MARK: - Lifecycle

    init(dbPool: any DatabaseWriter, dataType: SyncDataType) {
        self.dbPool = dbPool
        self.dataType = dataType
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

    func apply(_ payload: SyncPayload) async throws -> Bool {
        guard payload.dataType == dataType else {
            return false
        }

        return try await dbPool.write { db in
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

    func snapshotPayloads() async throws -> [SyncPayload] {
        try await dbPool.read { db in
            try SyncMetadataDB
                .filter(Column("dataType") == dataType.rawValue)
                .fetchAll(db)
                .map { metadata in
                    guard let recordID = UUID(uuidString: metadata.recordID) else {
                        throw GRDBSyncResourceError.invalidRecordIdentifier
                    }

                    return try SyncPayload(
                        recordID: recordID,
                        dataType: dataType,
                        version: metadata.version,
                        isDeleted: metadata.isDeleted,
                        data: snapshotData(for: metadata, in: db)
                    )
                }
        }
    }

    // MARK: - Private methods

    private func metadataRequest(recordID: UUID) -> QueryInterfaceRequest<SyncMetadataDB> {
        SyncMetadataDB
            .filter(Column("dataType") == dataType.rawValue && Column("recordID") == recordID.uuidString)
    }

    private func snapshotData(for metadata: SyncMetadataDB, in db: Database) throws -> Data {
        if metadata.isDeleted {
            return Data()
        }

        guard let record = try Record.fetchOne(db, key: metadata.recordID) else {
            throw GRDBSyncResourceError.missingRecord
        }

        return try encoder.encode(record.toPlain())
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
