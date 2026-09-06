import Foundation

enum WatchConnectivitySyncTransportError: Error, Equatable {
    case inactiveSession
    case unpaired
    case counterpartAppNotInstalled
}
