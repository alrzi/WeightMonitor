import Foundation

public protocol SyncService: Sendable {
    nonisolated func start()
    nonisolated func requestFlush()
}
