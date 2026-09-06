import Sync

enum WatchConnectivitySyncTransportEvent: Equatable, Sendable {
    case envelope(SyncEnvelope)
    case sessionDidBecomeReady
}
