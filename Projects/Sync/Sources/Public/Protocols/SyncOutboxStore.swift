import Foundation

public struct SyncRetryPolicy: Sendable {
    public let maximumAttemptCount: Int
    public let acknowledgementTimeout: TimeInterval

    public init(
        maximumAttemptCount: Int,
        acknowledgementTimeout: TimeInterval
    ) {
        precondition(maximumAttemptCount > 0)
        precondition(acknowledgementTimeout > 0)

        self.maximumAttemptCount = maximumAttemptCount
        self.acknowledgementTimeout = acknowledgementTimeout
    }
}

public protocol SyncOutboxStore: Sendable {
    func retryablePayloads() async throws -> [SyncPayload]
    func markSending(payloadID: UUID) async throws
    func markAwaitingAcknowledgement(payloadID: UUID) async throws
    func markFailed(payloadID: UUID) async throws
    func markSynced(payloadID: UUID) async throws
}
