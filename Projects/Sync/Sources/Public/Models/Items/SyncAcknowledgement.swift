import Foundation

public struct SyncAcknowledgement: Codable, Equatable, Sendable {
    public let payloadID: UUID

    public init(payloadID: UUID) {
        self.payloadID = payloadID
    }
}
