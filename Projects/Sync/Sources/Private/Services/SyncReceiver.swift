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

        _ = try await resourceRegistry.apply(payload)

        processedPayloadIDs.insert(payload.id)
        try await sendAcknowledgement(for: payload)
    }

    func receive(_ snapshot: SyncSnapshot) async throws {
        var firstError: (any Error)?

        for payload in snapshot.payloads {
            do {
                try await receive(payload)
            }
            catch {
                firstError = firstError ?? error
            }
        }

        if let firstError {
            throw firstError
        }
    }

    private func sendAcknowledgement(for payload: SyncPayload) async throws {
        try transport.send(.acknowledgement(.init(payloadID: payload.id)))
    }
}
