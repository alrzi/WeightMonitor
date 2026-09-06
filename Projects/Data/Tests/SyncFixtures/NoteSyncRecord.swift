import Foundation
internal import GRDB
@testable import Data

struct NoteSyncRecord: Codable, GRDBSyncRecord {
    let id: String
    let text: String

    static let databaseTableName = "notes"

    static func from(plain: NoteSyncValue) -> Self {
        Self(id: plain.id.uuidString, text: plain.text)
    }

    func toPlain() throws -> NoteSyncValue {
        guard let identifier = UUID(uuidString: id) else {
            throw GRDBSyncResourceError.invalidRecordIdentifier
        }

        return NoteSyncValue(id: identifier, text: text)
    }
}
