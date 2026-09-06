import Foundation
import OSLog
import Sync

final class WatchConnectivitySyncTransport: SyncTransport {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let session: any WatchConnectivitySession
    private var continuation: AsyncStream<WatchConnectivitySyncTransportEvent>.Continuation?

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
        case .payload, .acknowledgement:
            Logger.weightMonitorSync.info("Sending user info: \(data.count) bytes")
            session.transferUserInfo(["envelope": data])

        case .snapshot:
            Logger.weightMonitorSync.info("Updating application context: \(data.count) bytes")
            try session.updateApplicationContext(["envelope": data])
        }
    }
}

extension WatchConnectivitySyncTransport: WatchConnectivitySessionDelegate {
    func sessionActivationDidComplete() {
        notifySessionDidBecomeReadyIfAvailable()
    }

    func sessionAvailabilityDidChange() {
        notifySessionDidBecomeReadyIfAvailable()
    }

    func sessionDidReceiveMessageData(_ data: Data) {
        receive(data)
    }

    func sessionDidReceiveUserInfo(_ userInfo: [String: Any]) {
        receiveEnvelope(from: userInfo)
    }

    func sessionDidReceiveApplicationContext(_ applicationContext: [String: Any]) {
        receiveEnvelope(from: applicationContext)
    }

    private func notifySessionDidBecomeReadyIfAvailable() {
        guard session.availability == .ready else {
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

    private func receive(_ data: Data) {
        guard let envelope = try? decoder.decode(SyncEnvelope.self, from: data) else {
            return
        }

        continuation?.yield(.envelope(envelope))
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
