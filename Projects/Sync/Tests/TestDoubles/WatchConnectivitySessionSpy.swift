import Foundation
import Sync
@testable import SyncImplementation

final class WatchConnectivitySessionSpy: WatchConnectivitySession {
    weak var delegate: (any WatchConnectivitySessionDelegate)?

    var availability: WatchConnectivitySessionAvailability
    private(set) var activateCallCount = 0
    private(set) var transferredUserInfo: [[String: Any]] = []
    private(set) var updatedApplicationContexts: [[String: Any]] = []
    var applicationContextUpdateError: (any Error)?

    init(availability: WatchConnectivitySessionAvailability = .ready) {
        self.availability = availability
    }

    func activate() {
        activateCallCount += 1
    }

    func transferUserInfo(_ userInfo: [String: Any]) {
        transferredUserInfo.append(userInfo)
    }

    func updateApplicationContext(_ applicationContext: [String: Any]) throws {
        if let applicationContextUpdateError {
            throw applicationContextUpdateError
        }

        updatedApplicationContexts.append(applicationContext)
    }

    func completeActivation() {
        delegate?.sessionActivationDidComplete()
    }

    func changeAvailability(to availability: WatchConnectivitySessionAvailability) {
        self.availability = availability
        delegate?.sessionAvailabilityDidChange()
    }

    func receiveMessageData(_ data: Data) {
        delegate?.sessionDidReceiveMessageData(data)
    }

    func receiveUserInfo(_ userInfo: [String: Any]) {
        delegate?.sessionDidReceiveUserInfo(userInfo)
    }

    func receiveApplicationContext(_ applicationContext: [String: Any]) {
        delegate?.sessionDidReceiveApplicationContext(applicationContext)
    }
}
