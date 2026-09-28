import Foundation

protocol WatchConnectivitySessionDelegate: AnyObject {
    func sessionActivationDidComplete()
    func sessionAvailabilityDidChange()
    func sessionDidReceiveMessageData(_ data: Data)
    func sessionDidReceiveUserInfo(_ userInfo: [String: Any])
}
