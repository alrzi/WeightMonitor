import Foundation
import OSLog
import Sync

final class WatchConnectivitySyncTransport: SyncTransport {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let session: any WatchConnectivitySession
    private let directMessageReplies = DirectMessageReplies()
    private var continuation: AsyncStream<WatchConnectivitySyncTransportEvent>.Continuation?
    private var lastSessionAvailability: WatchConnectivitySessionAvailability = .inactive

    var isReady: Bool {
        session.availability == .ready
    }

    init(session: some WatchConnectivitySession) {
        self.session = session
    }

    func activate() -> AsyncStream<WatchConnectivitySyncTransportEvent> {
        let stream = AsyncStream<WatchConnectivitySyncTransportEvent>.makeStream()

        continuation = stream.continuation
        session.delegate = self
        session.activate()

        return stream.stream
    }

    func send(_ envelope: SyncEnvelope) throws {
        try session.availability.validate()

        let data = try encoder.encode(envelope)

        switch envelope {
        case .payload where session.isReachable:
            sendMessageData(data)

        case .payload, .acknowledgement:
            transferUserInfo(data)
        }
    }

    func acknowledgeDirectPayload(payloadID: UUID) throws {
        let acknowledgement = SyncEnvelope.acknowledgement(.init(payloadID: payloadID))
        let data = try encoder.encode(acknowledgement)
        directMessageReplies.reply(with: data, for: payloadID)
    }

    func discardDirectPayloadReply(payloadID: UUID) {
        directMessageReplies.remove(for: payloadID)
    }
}

extension WatchConnectivitySyncTransport: WatchConnectivitySessionDelegate {
    func sessionActivationDidComplete() {
        updateSessionReadiness(session.availability)
    }

    func sessionAvailabilityDidChange() {
        updateSessionReadiness(session.availability)
    }

    func sessionDidReceiveMessageData(
        _ data: Data,
        replyHandler: @escaping (Data) -> Void
    ) {
        receiveMessageData(data, replyHandler: replyHandler)
    }

    func sessionDidReceiveMessageDataReply(_ data: Data) {
        receive(data)
    }

    func sessionDidFailToSendMessageData(_ data: Data, error: any Error) {
        transferUserInfo(data)
    }

    func sessionDidReceiveUserInfo(_ userInfo: [String: Any]) {
        receiveEnvelope(from: userInfo)
    }
}

private extension WatchConnectivitySyncTransport {
    private func updateSessionReadiness(_ availability: WatchConnectivitySessionAvailability) {
        defer {
            lastSessionAvailability = availability
        }

        guard availability == .ready, lastSessionAvailability != .ready else {
            return
        }

        continuation?.yield(.sessionDidBecomeReady)
    }

    private func receiveEnvelope(from dictionary: [String: Any]) {
        guard let data = dictionary["envelope"] as? Data else {
            return
        }

        receive(data)
    }

    private func sendMessageData(_ data: Data) {
        Logger.weightMonitorSync.info("Sending message data: \(data.count) bytes")
        session.sendMessageData(data)
    }

    private func transferUserInfo(_ data: Data) {
        Logger.weightMonitorSync.info("Sending user info: \(data.count) bytes")
        session.transferUserInfo(["envelope": data])
    }

    private func receiveMessageData(
        _ data: Data,
        replyHandler: @escaping (Data) -> Void
    ) {
        guard let envelope = try? decoder.decode(SyncEnvelope.self, from: data) else {
            return
        }

        switch envelope {
        case .payload(let payload):
            directMessageReplies.store(replyHandler, for: payload.id)
            continuation?.yield(.directPayload(payload))

        case .acknowledgement:
            continuation?.yield(.envelope(envelope))
        }
    }

    private func receive(_ data: Data) {
        guard let envelope = try? decoder.decode(SyncEnvelope.self, from: data) else {
            return
        }

        continuation?.yield(.envelope(envelope))
    }
}

private final class DirectMessageReplies {
    private let lock = NSLock()
    private var handlers: [UUID: (Data) -> Void] = [:]

    func store(_ handler: @escaping (Data) -> Void, for payloadID: UUID) {
        lock.withLock {
            handlers[payloadID] = handler
        }
    }

    func reply(with data: Data, for payloadID: UUID) {
        let handler = lock.withLock {
            handlers.removeValue(forKey: payloadID)
        }
        handler?(data)
    }

    func remove(for payloadID: UUID) {
        _ = lock.withLock {
            handlers.removeValue(forKey: payloadID)
        }
    }
}

private extension WatchConnectivitySessionAvailability {
    // MARK: - Private methods

    func validate() throws {
        switch self {
        case .inactive:
            throw WatchConnectivitySyncTransportError.inactiveSession

        case .unpaired:
            throw WatchConnectivitySyncTransportError.unpaired

        case .counterpartAppNotInstalled:
            throw WatchConnectivitySyncTransportError.counterpartAppNotInstalled

        case .ready:
            return
        }
    }
}
