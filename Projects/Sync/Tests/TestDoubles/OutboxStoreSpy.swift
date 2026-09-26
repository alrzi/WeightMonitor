import Foundation
import Sync
@testable import SyncImplementation

actor OutboxStoreSpy: SyncOutboxStore {
    enum Event: Equatable {
        case markedSending(UUID),
             markedAwaitingAcknowledgement(UUID),
             markedFailed(UUID),
             markedSynced(UUID)
    }

    private let payloads: [SyncPayload]
    private let awaitingAcknowledgementPayloads: [SyncPayload]
    private(set) var events: [Event] = []

    init(
        payloads: [SyncPayload],
        awaitingAcknowledgementPayloads: [SyncPayload] = []
    ) {
        self.payloads = payloads
        self.awaitingAcknowledgementPayloads = awaitingAcknowledgementPayloads
    }

    func retryablePayloads() -> [SyncPayload] {
        payloads + awaitingAcknowledgementPayloads
    }

    func markSending(payloadID: UUID) {
        events.append(.markedSending(payloadID))
    }

    func markAwaitingAcknowledgement(payloadID: UUID) {
        events.append(.markedAwaitingAcknowledgement(payloadID))
    }

    func markFailed(payloadID: UUID) {
        events.append(.markedFailed(payloadID))
    }

    func markSynced(payloadID: UUID) {
        events.append(.markedSynced(payloadID))
    }
}
