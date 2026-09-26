import Foundation

public protocol SyncResource: Sendable {
    var dataType: SyncDataType { get }

    func applyMatching(_ payload: SyncPayload) async throws -> Bool
    func snapshotPayloads() async throws -> [SyncPayload]
}

public extension SyncResource {
    func apply(_ payload: SyncPayload) async throws -> Bool {
        guard payload.dataType == dataType else {
            return false
        }

        return try await applyMatching(payload)
    }
}
