import Foundation
import Sync
@testable import SyncImplementation
import Testing

@Suite
struct SyncOrchestratorTests {
    @Test func flushMarksPayloadAwaitingAcknowledgementAfterSend() async throws {
        // GIVEN
        let payload = makePayload()
        let store = OutboxStoreSpy(payloads: [payload])
        let transport = TransportSpy()
        let orchestrator = SyncOrchestrator(outboxStore: store, transport: transport)
        // WHEN
        try await orchestrator.flush()

        // THEN
        #expect(await store.events == [.recoveredInterruptedDeliveries, .markedSending(payload.id), .markedAwaitingAcknowledgement(payload.id)])
        #expect(transport.sentPayloadIDs == [payload.id])
    }

    @Test func flushMarksPayloadFailedWhenTransportThrows() async throws {
        // GIVEN
        let payload = makePayload()
        let store = OutboxStoreSpy(payloads: [payload])
        let transport = TransportSpy(error: .failed)
        let orchestrator = SyncOrchestrator(outboxStore: store, transport: transport)
        // WHEN
        try await orchestrator.flush()

        // THEN
        #expect(await store.events == [.recoveredInterruptedDeliveries, .markedSending(payload.id), .markedFailed(payload.id)])
    }

    @Test func acknowledgeMarksPayloadSynced() async throws {
        // GIVEN
        let payload = makePayload()
        let store = OutboxStoreSpy(payloads: [])
        let transport = TransportSpy()
        let orchestrator = SyncOrchestrator(outboxStore: store, transport: transport)
        // WHEN
        try await orchestrator.acknowledge(.init(payloadID: payload.id))

        // THEN
        #expect(await store.events == [.markedSynced(payload.id)])
    }

    private func makePayload() -> SyncPayload {
        SyncPayload(
            recordID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            dataType: SyncDataType(rawValue: "weight"),
            version: SyncVersion(
                physicalTime: Date(timeIntervalSince1970: 1000),
                logicalCounter: 0,
                deviceID: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
            ),
            isDeleted: false,
            data: Data()
        )
    }
}
