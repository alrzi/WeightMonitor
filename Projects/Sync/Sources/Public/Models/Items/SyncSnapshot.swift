import Foundation

public struct SyncSnapshot: Codable, Equatable, Sendable {
    public let payloads: [SyncPayload]

    public init(payloads: [SyncPayload]) {
        self.payloads = payloads
    }
}
