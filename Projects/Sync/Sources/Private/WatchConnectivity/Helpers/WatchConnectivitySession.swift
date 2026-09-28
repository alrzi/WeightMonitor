import Foundation

protocol WatchConnectivitySession: AnyObject {
    var delegate: (any WatchConnectivitySessionDelegate)? { get set }
    var availability: WatchConnectivitySessionAvailability { get }
    var isReachable: Bool { get }

    func activate()
    func sendMessageData(_ data: Data)
    func transferUserInfo(_ userInfo: [String: Any])
}
