import Foundation
import Sync
@testable import SyncImplementation

actor OutboxStoreSpy: SyncOutboxStore {
    enum Event: Equatable {
        case recoveredInterruptedDeliveries,
             markedSending(UUID),
             markedAwaitingAcknowledgement(UUID),
             markedFailed(UUID),
             markedSynced(UUID)
    }

    private let payloads: [SyncPayload]
    private(set) var events: [Event] = []

    init(payloads: [SyncPayload]) {
        self.payloads = payloads
    }

    func recoverInterruptedDeliveries() {
        events.append(.recoveredInterruptedDeliveries)
    }

    func pendingPayloads() -> [SyncPayload] {
        payloads
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
