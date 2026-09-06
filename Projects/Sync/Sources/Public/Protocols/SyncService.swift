import Foundation

public protocol SyncService: Sendable {
    nonisolated func start()
    func flush() async throws
}
