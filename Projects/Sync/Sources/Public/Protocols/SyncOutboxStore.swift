import Foundation

public protocol SyncOutboxStore: Sendable {
    func retryablePayloads() async throws -> [SyncPayload]
    func markSending(payloadID: UUID) async throws
    func markAwaitingAcknowledgement(payloadID: UUID) async throws
    func markFailed(payloadID: UUID) async throws
    func markSynced(payloadID: UUID) async throws
}
