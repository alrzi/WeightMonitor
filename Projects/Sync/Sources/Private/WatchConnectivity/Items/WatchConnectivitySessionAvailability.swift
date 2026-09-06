import Foundation

enum WatchConnectivitySessionAvailability: Equatable, Sendable {
    case inactive
    case unpaired
    case counterpartAppNotInstalled
    case ready
}
