import Foundation
import Sync

final class SyncReceiver {
    private let resourceRegistry: SyncResourceRegistry
    private let transport: any SyncTransport

    private var processedPayloadIDs: Set<UUID> = []

    init(resourceRegistry: SyncResourceRegistry, transport: some SyncTransport) {
        self.resourceRegistry = resourceRegistry
        self.transport = transport
    }

    func receive(_ payload: SyncPayload) async throws {
        guard !processedPayloadIDs.contains(payload.id) else {
            try await sendAcknowledgement(for: payload)
            return
        }

        processedPayloadIDs.insert(payload.id)

        let wasApplied = try await resourceRegistry.apply(payload)

        guard wasApplied else {
            return
        }

        try await sendAcknowledgement(for: payload)
    }

    private func sendAcknowledgement(for payload: SyncPayload) async throws {
        try transport.send(.acknowledgement(.init(payloadID: payload.id)))
    }
}
