import Foundation
import Sync
@testable import SyncImplementation
import Testing

@Suite
struct SyncEnvelopeTests {
    @Test
    func roundTripsPayloadAndAcknowledgement() throws {
        // GIVEN
        let version = SyncVersion(physicalTime: Date(timeIntervalSince1970: 1000), logicalCounter: 1, deviceID: makeDeviceID(1))

        let payload = SyncPayload(
            id: makeDeviceID(3),
            recordID: makeDeviceID(4),
            dataType: SyncDataType(rawValue: "weight"),
            version: version,
            isDeleted: false,
            data: Data("weight".utf8)
        )

        let envelopes: [SyncEnvelope] = [
            .payload(payload),
            .acknowledgement(.init(payloadID: payload.id))
        ]

        // WHEN
        let decoded = try envelopes.map { try JSONDecoder().decode(SyncEnvelope.self, from: JSONEncoder().encode($0)) }

        // THEN
        #expect(decoded == envelopes)
    }

    private func makeDeviceID(_ value: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", value))!
    }
}
