import Foundation
import Sync
@testable import SyncImplementation

actor OutboxStoreSpy: SyncOutboxStore {
    private struct Delivery {
        let payload: SyncPayload
        var status: OutboxStatus
        var attemptCount: Int
        var isAcknowledgementTimedOut: Bool
    }

    enum Event: Equatable {
        case markedSending(UUID),
             markedAwaitingAcknowledgement(UUID),
             markedFailed(UUID),
             markedSynced(UUID)
    }

    private var deliveriesByID: [UUID: Delivery]
    private let retryPolicy: SyncRetryPolicy
    private(set) var events: [Event] = []

    init(
        payloads: [SyncPayload],
        awaitingAcknowledgementPayloads: [SyncPayload] = [],
        retryPolicy: SyncRetryPolicy = .init(
            maximumAttemptCount: 3,
            acknowledgementTimeout: 60
        )
    ) {
        self.retryPolicy = retryPolicy
        deliveriesByID = Dictionary(
            uniqueKeysWithValues: payloads.map {
                ($0.id, Delivery(payload: $0, status: .pending, attemptCount: 0, isAcknowledgementTimedOut: false))
            } + awaitingAcknowledgementPayloads.map {
                ($0.id, Delivery(payload: $0, status: .awaitingAcknowledgement, attemptCount: 1, isAcknowledgementTimedOut: true))
            }
        )
    }

    func retryablePayloads() -> [SyncPayload] {
        deliveriesByID.values
            .filter { delivery in
                guard delivery.attemptCount < retryPolicy.maximumAttemptCount else {
                    return false
                }

                switch delivery.status {
                case .pending, .sending, .failed:
                    return true

                case .awaitingAcknowledgement:
                    return delivery.isAcknowledgementTimedOut

                case .synced:
                    return false
                }
            }
            .map(\.payload)
    }

    func markSending(payloadID: UUID) {
        events.append(.markedSending(payloadID))
        deliveriesByID[payloadID]?.status = .sending
        deliveriesByID[payloadID]?.attemptCount += 1
        deliveriesByID[payloadID]?.isAcknowledgementTimedOut = false
    }

    func markAwaitingAcknowledgement(payloadID: UUID) {
        events.append(.markedAwaitingAcknowledgement(payloadID))
        deliveriesByID[payloadID]?.status = .awaitingAcknowledgement
    }

    func markFailed(payloadID: UUID) {
        events.append(.markedFailed(payloadID))
        deliveriesByID[payloadID]?.status = .failed
    }

    func markSynced(payloadID: UUID) {
        events.append(.markedSynced(payloadID))
        deliveriesByID[payloadID]?.status = .synced
    }
}
