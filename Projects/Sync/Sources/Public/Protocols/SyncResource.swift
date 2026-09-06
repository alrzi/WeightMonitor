import Foundation

public protocol SyncResource: Sendable {
    var dataType: SyncDataType { get }

    func apply(_ payload: SyncPayload) async throws -> Bool
    func snapshotPayloads() async throws -> [SyncPayload]
}
