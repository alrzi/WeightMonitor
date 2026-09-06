import Foundation
internal import GRDB

struct SyncStateDB: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "syncState"

    let key: String
    let value: Data
}
