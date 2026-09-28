import Foundation
import Sync

enum WatchConnectivitySyncTransportEvent: Equatable, Sendable {
    case envelope(SyncEnvelope)
    case directPayload(SyncPayload)
    case sessionDidBecomeReady
}
