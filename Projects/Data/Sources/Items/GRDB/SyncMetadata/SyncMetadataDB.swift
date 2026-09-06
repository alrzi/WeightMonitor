import Foundation
internal import GRDB

struct SyncMetadataDB: Codable, FetchableRecord, PersistableRecord {
    // MARK: - Internal properties

    let dataType: String
    let recordID: String
    let physicalTime: Date
    let logicalCounter: Int64
    let originDeviceID: String
    let isDeleted: Bool
}

extension SyncMetadataDB {
    // MARK: - Static properties

    static let databaseTableName = "syncMetadata"
}
