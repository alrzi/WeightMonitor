import Foundation
import Sync
@testable import SyncImplementation

final class TransportSpy: SyncTransport {
    private let error: TransportError?
    private(set) var sentPayloadIDs: [UUID] = []
    private(set) var sentAcknowledgementIDs: [UUID] = []
    init(error: TransportError? = nil) {
        self.error = error
    }

    func send(_ envelope: SyncEnvelope) throws {
        if let error { throw error }
        if case let .payload(payload) = envelope { sentPayloadIDs.append(payload.id) }
        else if case let .acknowledgement(acknowledgement) = envelope { sentAcknowledgementIDs.append(acknowledgement.payloadID) }
    }
}
