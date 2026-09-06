import Foundation
import Sync
@testable import SyncImplementation
import Testing

@Suite
struct SyncReceiverTests {
    @Test func appliesPayloadOnceAndAcknowledgesDuplicate() async throws {
        // GIVEN
        let payload = makePayload()
        let applier = PayloadApplierSpy()
        let transport = TransportSpy()
        let receiver = SyncReceiver(resourceRegistry: SyncResourceRegistry(resources: [applier]), transport: transport)
        // WHEN
        try await receiver.receive(.payload(payload))
        try await receiver.receive(.payload(payload))
        // THEN
        #expect(await applier.appliedPayloadIDs == [payload.id])
        #expect(transport.sentAcknowledgementIDs == [payload.id, payload.id])
    }

    @Test func appliesSnapshotPayloadOnceAndAcknowledgesRepeatedSnapshot() async throws {
        // GIVEN
        let payload = makePayload()
        let applier = PayloadApplierSpy()
        let transport = TransportSpy()
        let receiver = SyncReceiver(resourceRegistry: SyncResourceRegistry(resources: [applier]), transport: transport)
        let snapshot = SyncSnapshot(payloads: [payload])
        // WHEN
        try await receiver.receive(.snapshot(snapshot))
        try await receiver.receive(.snapshot(snapshot))
        // THEN
        #expect(await applier.appliedPayloadIDs == [payload.id])
        #expect(transport.sentAcknowledgementIDs == [payload.id, payload.id])
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
