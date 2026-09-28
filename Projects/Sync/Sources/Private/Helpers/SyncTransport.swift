import Foundation
import Sync

protocol SyncTransport {
    func send(_ envelope: SyncEnvelope) throws
}
