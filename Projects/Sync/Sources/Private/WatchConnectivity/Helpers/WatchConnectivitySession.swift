import Foundation

protocol WatchConnectivitySession: AnyObject {
    var delegate: (any WatchConnectivitySessionDelegate)? { get set }
    var availability: WatchConnectivitySessionAvailability { get }

    func activate()
    func transferUserInfo(_ userInfo: [String: Any])
    func updateApplicationContext(_ applicationContext: [String: Any]) throws
}
