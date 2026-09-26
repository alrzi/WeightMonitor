import Foundation
internal import GRDB
import Sync

protocol GRDBSyncRecord: FetchableRecord, PersistableRecord, Sendable {
    associatedtype Value: Codable, Identifiable, Sendable where Value.ID == UUID

    static var syncDataType: SyncDataType { get }

    static func from(plain: Value) -> Self
    func toPlain() throws -> Value
}
