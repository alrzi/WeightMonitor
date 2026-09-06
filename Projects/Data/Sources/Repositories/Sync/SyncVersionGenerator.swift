import Foundation
internal import GRDB
import Sync

struct SyncVersionGenerator {
    // MARK: - Internal methods

    // Allocate and persist the version inside the mutation transaction, across all resources.
    func next(in db: Database) throws -> SyncVersion {
        let deviceID: UUID

        if let state = try SyncStateDB.fetchOne(db, key: "deviceID") {
            guard
                let value = String(data: state.value, encoding: .utf8),
                let identifier = UUID(uuidString: value)
            else {
                throw SyncStateStoreError.invalidDeviceID
            }

            deviceID = identifier
        }
        else {
            deviceID = UUID()
            try SyncStateDB(key: "deviceID", value: Data(deviceID.uuidString.utf8)).insert(db)
        }

        let savedVersion = try SyncStateDB.fetchOne(db, key: "version")
            .map { try JSONDecoder().decode(SyncVersion.self, from: $0.value) }

        let latestMetadata = try SyncMetadataDB
            .order(Column("physicalTime").desc, Column("logicalCounter").desc)
            .fetchOne(db)

        let latestVersion = try [savedVersion, latestMetadata?.version].compactMap { $0 }.max()
        let physicalTime = max(Date(), latestVersion?.physicalTime ?? .distantPast)
        var logicalCounter: UInt64 = 0

        if let latestVersion, physicalTime == latestVersion.physicalTime {
            guard latestVersion.logicalCounter < UInt64(Int64.max) else {
                throw GRDBSyncResourceError.logicalCounterOverflow
            }

            logicalCounter = latestVersion.logicalCounter + 1
        }

        let version = SyncVersion(
            physicalTime: physicalTime,
            logicalCounter: logicalCounter,
            deviceID: deviceID
        )
        try SyncStateDB(key: "version", value: JSONEncoder().encode(version)).upsert(db)

        return version
    }
}
