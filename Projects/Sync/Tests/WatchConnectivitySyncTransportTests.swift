import Foundation
import Testing
import Sync
@testable import SyncImplementation

@Suite(.serialized)
final class WatchConnectivitySyncTransportTests {
    @Test
    func test_sendPayloadTransfersUserInfo() throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let transport = WatchConnectivitySyncTransport(session: session)
        let envelope = makeEnvelope()

        // WHEN
        try transport.send(envelope)

        // THEN
        let transferredData = try #require(session.transferredUserInfo.first?["envelope"] as? Data)
        let transferredEnvelope = try JSONDecoder().decode(SyncEnvelope.self, from: transferredData)
        #expect(transferredEnvelope == envelope)
        #expect(session.updatedApplicationContexts.isEmpty)
    }

    @Test
    func test_sendAcknowledgementTransfersUserInfo() throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let transport = WatchConnectivitySyncTransport(session: session)
        let envelope = SyncEnvelope.acknowledgement(.init(payloadID: UUID()))

        // WHEN
        try transport.send(envelope)

        // THEN
        let transferredData = try #require(session.transferredUserInfo.first?["envelope"] as? Data)
        let transferredEnvelope = try JSONDecoder().decode(SyncEnvelope.self, from: transferredData)
        #expect(transferredEnvelope == envelope)
        #expect(session.updatedApplicationContexts.isEmpty)
    }

    @Test
    func test_sendMultiplePayloadsCreatesSeparateOrderedUserInfoTransfers() throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let transport = WatchConnectivitySyncTransport(session: session)
        let envelopes = (0 ..< 10).map { _ in makePayloadEnvelope() }

        // WHEN
        for envelope in envelopes {
            try transport.send(envelope)
        }

        // THEN
        let transferredEnvelopes = try session.transferredUserInfo
            .map { try #require($0["envelope"] as? Data) }
            .map { try JSONDecoder().decode(SyncEnvelope.self, from: $0) }

        #expect(transferredEnvelopes == envelopes)
    }

    @Test
    func test_sendSnapshotUpdatesApplicationContext() throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let transport = WatchConnectivitySyncTransport(session: session)
        let envelope = SyncEnvelope.snapshot(.init(payloads: []))

        // WHEN
        try transport.send(envelope)

        // THEN
        let contextData = try #require(session.updatedApplicationContexts.first?["envelope"] as? Data)
        let contextEnvelope = try JSONDecoder().decode(SyncEnvelope.self, from: contextData)
        #expect(contextEnvelope == envelope)
        #expect(session.transferredUserInfo.isEmpty)
    }

    @Test(arguments: [
        (WatchConnectivitySessionAvailability.inactive, WatchConnectivitySyncTransportError.inactiveSession),
        (.unpaired, .unpaired),
        (.counterpartAppNotInstalled, .counterpartAppNotInstalled)
    ])
    func test_sendThrowsWhenSessionIsUnavailable(
        availability: WatchConnectivitySessionAvailability,
        expectedError: WatchConnectivitySyncTransportError
    ) {
        // GIVEN
        let session = WatchConnectivitySessionSpy(availability: availability)
        let transport = WatchConnectivitySyncTransport(session: session)

        // WHEN / THEN
        #expect(throws: expectedError) {
            try transport.send(makeEnvelope())
        }
        #expect(session.transferredUserInfo.isEmpty)
        #expect(session.updatedApplicationContexts.isEmpty)
    }

    @Test
    func test_incomingMessageDataIsDecodedAndForwarded() async throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let envelope = makeEnvelope()
        let transport = WatchConnectivitySyncTransport(session: session)

        // WHEN
        let events = transport.activate()
        session.receiveMessageData(try JSONEncoder().encode(envelope))

        // THEN
        var iterator = events.makeAsyncIterator()
        #expect(await iterator.next() == .envelope(envelope))
        withExtendedLifetime(transport) {}
    }

    @Test
    func test_incomingUserInfoIsDecodedAndForwarded() async throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let envelope = makeEnvelope()
        let transport = WatchConnectivitySyncTransport(session: session)

        // WHEN
        let events = transport.activate()
        session.receiveUserInfo(["envelope": try JSONEncoder().encode(envelope)])

        // THEN
        var iterator = events.makeAsyncIterator()
        #expect(await iterator.next() == .envelope(envelope))
        withExtendedLifetime(transport) {}
    }

    @Test
    func test_incomingApplicationContextIsDecodedAndForwarded() async throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let envelope = makeEnvelope()
        let transport = WatchConnectivitySyncTransport(session: session)

        // WHEN
        let events = transport.activate()
        session.receiveApplicationContext(["envelope": try JSONEncoder().encode(envelope)])

        // THEN
        var iterator = events.makeAsyncIterator()
        #expect(await iterator.next() == .envelope(envelope))
        withExtendedLifetime(transport) {}
    }

    @Test
    func test_invalidIncomingDataAndDictionariesAreIgnored() async throws {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let envelope = makeEnvelope()
        let transport = WatchConnectivitySyncTransport(session: session)

        // WHEN
        let events = transport.activate()
        session.receiveMessageData(Data("Invalid".utf8))
        session.receiveUserInfo([:])
        session.receiveApplicationContext([:])
        session.receiveMessageData(try JSONEncoder().encode(envelope))

        // THEN
        var iterator = events.makeAsyncIterator()
        #expect(await iterator.next() == .envelope(envelope))
        withExtendedLifetime(transport) {}
    }

    @Test
    func test_activationAndRepeatedReadyAvailabilityChangeNotifyReadyHandlerOnce() async {
        // GIVEN
        let session = WatchConnectivitySessionSpy()
        let transport = WatchConnectivitySyncTransport(session: session)

        // WHEN
        let events = transport.activate()
        session.completeActivation()
        session.changeAvailability(to: .ready)

        // THEN
        var iterator = events.makeAsyncIterator()
        #expect(await iterator.next() == .sessionDidBecomeReady)
        #expect(session.activateCallCount == 1)
        withExtendedLifetime(transport) {}
    }

    private func makeEnvelope() -> SyncEnvelope {
        .acknowledgement(.init(payloadID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!))
    }

    private func makePayloadEnvelope() -> SyncEnvelope {
        .payload(
            .init(
                recordID: UUID(),
                dataType: SyncDataType(rawValue: "weight"),
                version: .init(physicalTime: .now, logicalCounter: 0, deviceID: UUID()),
                isDeleted: false,
                data: Data()
            )
        )
    }
}
