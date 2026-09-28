import Foundation

protocol WatchConnectivitySessionDelegate: AnyObject {
    func sessionActivationDidComplete()
    func sessionAvailabilityDidChange()
    func sessionDidReceiveMessageData(
        _ data: Data,
        replyHandler: @escaping (Data) -> Void
    )
    func sessionDidReceiveMessageDataReply(_ data: Data)
    func sessionDidFailToSendMessageData(_ data: Data, error: any Error)
    func sessionDidReceiveUserInfo(_ userInfo: [String: Any])
}
