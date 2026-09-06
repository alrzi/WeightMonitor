import Foundation
internal import GRDB

protocol GRDBSyncRecord: FetchableRecord, PersistableRecord, Sendable {
    associatedtype Value: Codable, Identifiable, Sendable where Value.ID == UUID

    static func from(plain: Value) -> Self
    func toPlain() throws -> Value
}
