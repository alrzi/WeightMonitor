import Foundation
internal import GRDB
import Sync

struct SyncStateStore {
    // MARK: - Private static properties

    private static let deviceIDKey = "deviceID"
    private static let versionKey = "version"

    // MARK: - Private properties

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let dbPool: any DatabaseWriter

    // MARK: - Lifecycle

    init(dbPool: any DatabaseWriter) {
        self.dbPool = dbPool
    }

    // MARK: - Internal methods

    func loadOrCreateDeviceID() async throws -> UUID {
        try await dbPool.write { db in
            if let state = try SyncStateDB.fetchOne(db, key: Self.deviceIDKey) {
                guard
                    let value = String(data: state.value, encoding: .utf8),
                    let deviceID = UUID(uuidString: value)
                else {
                    throw SyncStateStoreError.invalidDeviceID
                }

                return deviceID
            }

            let deviceID = UUID()
            try SyncStateDB(
                key: Self.deviceIDKey,
                value: Data(deviceID.uuidString.utf8)
            )
            .insert(db)

            return deviceID
        }
    }

    func loadVersion() async throws -> SyncVersion? {
        try await dbPool.read { db in
            guard let state = try SyncStateDB.fetchOne(db, key: Self.versionKey) else {
                return nil
            }

            return try decoder.decode(SyncVersion.self, from: state.value)
        }
    }

    func save(version: SyncVersion) async throws {
        try await dbPool.write { db in
            try SyncStateDB(
                key: Self.versionKey,
                value: encoder.encode(version)
            )
            .upsert(db)
        }
    }
}
