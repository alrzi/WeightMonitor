import Foundation
import Sync

protocol SyncTransport: Sendable {
    func send(_ envelope: SyncEnvelope) throws
}
