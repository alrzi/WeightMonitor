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
        try await receiver.receive(payload)
        try await receiver.receive(payload)
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
        for _ in 0..<2 {
            for payload in snapshot.payloads {
                try await receiver.receive(payload)
            }
        }
        // THEN
        #expect(await applier.appliedPayloadIDs == [payload.id])
        #expect(transport.sentAcknowledgementIDs == [payload.id, payload.id])
    }

    @Test func retriesPayloadAfterApplyingItFails() async throws {
        // GIVEN
        let payload = makePayload()
        let applier = PayloadApplierSpy(failuresBeforeSuccess: 1)
        let transport = TransportSpy()
        let receiver = SyncReceiver(resourceRegistry: SyncResourceRegistry(resources: [applier]), transport: transport)

        // WHEN
        var firstAttemptFailed = false

        do {
            try await receiver.receive(payload)
        }
        catch {
            firstAttemptFailed = true
        }

        try await receiver.receive(payload)

        // THEN
        #expect(firstAttemptFailed)
        #expect(await applier.appliedPayloadIDs == [payload.id, payload.id])
        #expect(transport.sentAcknowledgementIDs == [payload.id])
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
