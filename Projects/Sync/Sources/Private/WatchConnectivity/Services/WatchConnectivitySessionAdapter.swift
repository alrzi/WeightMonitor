import Foundation
import OSLog
import WatchConnectivity

final class WatchConnectivitySessionAdapter: NSObject, WatchConnectivitySession {
    private let session: WCSession

    weak var delegate: (any WatchConnectivitySessionDelegate)?

    var availability: WatchConnectivitySessionAvailability {
        guard session.activationState == .activated else {
            return .inactive
        }

        #if os(iOS)
        guard session.isPaired else {
            return .unpaired
        }

        guard session.isWatchAppInstalled else {
            return .counterpartAppNotInstalled
        }
        #elseif os(watchOS)
        guard session.isCompanionAppInstalled else {
            return .counterpartAppNotInstalled
        }
        #endif

        return .ready
    }

    var isReachable: Bool {
        session.isReachable
    }

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
    }

    func activate() {
        session.activate()
    }

    func sendMessageData(_ data: Data) {
        session.sendMessageData(
            data,
            replyHandler: { [weak self] in
                self?.delegate?.sessionDidReceiveMessageDataReply($0)
            },
            errorHandler: { [weak self] error in
                self?.delegate?.sessionDidFailToSendMessageData(data, error: error)
            }
        )
    }

    func transferUserInfo(_ userInfo: [String: Any]) {
        session.transferUserInfo(userInfo)
    }
}

extension WatchConnectivitySessionAdapter: WCSessionDelegate {
    public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        if error != nil {
            Logger.weightMonitorSync.error("WCSession activation failed: \(error?.localizedDescription ?? "Unknown error", privacy: .public)")
        }

        delegate?.sessionActivationDidComplete()
    }

    public func sessionReachabilityDidChange(_ session: WCSession) {
        delegate?.sessionAvailabilityDidChange()
    }

    #if os(iOS)
    public func sessionWatchStateDidChange(_ session: WCSession) {
        delegate?.sessionAvailabilityDidChange()
    }
    #endif

    public func session(
        _ session: WCSession,
        didReceiveMessageData messageData: Data,
        replyHandler: @escaping (Data) -> Void
    ) {
        delegate?.sessionDidReceiveMessageData(
            messageData,
            replyHandler: replyHandler
        )
    }

    public func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {}

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        delegate?.sessionDidReceiveUserInfo(userInfo)
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}

    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
