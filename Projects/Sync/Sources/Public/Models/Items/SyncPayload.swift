import Foundation

public struct SyncPayload: Codable, Equatable, Sendable {
    public let id: UUID
    public let recordID: UUID
    public let dataType: SyncDataType
    public let version: SyncVersion
    public let isDeleted: Bool
    public let data: Data

    public init(
        id: UUID = UUID(),
        recordID: UUID,
        dataType: SyncDataType,
        version: SyncVersion,
        isDeleted: Bool,
        data: Data
    ) {
        self.id = id
        self.recordID = recordID
        self.dataType = dataType
        self.version = version
        self.isDeleted = isDeleted
        self.data = data
    }
}
