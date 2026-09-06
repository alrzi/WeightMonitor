import Domain
import Foundation
import OSLog
import Sync

public final class WeightSyncRuntime {
    // MARK: - Private properties

    private let syncRuntime: any SyncService
    private let weightManager: any WeightManaging
    private var isStarted = false
    private var weightsObservationTask: Task<Void, Never>?

    // MARK: - Lifecycle

    public init(
        syncRuntime: some SyncService,
        weightManager: some WeightManaging
    ) {
        self.syncRuntime = syncRuntime
        self.weightManager = weightManager
    }

    // MARK: - Public methods

    public func start() {
        guard !isStarted else {
            return
        }

        isStarted = true
        observeWeightChanges()
        syncRuntime.start()
    }

    // MARK: - Private methods

    private func observeWeightChanges() {
        weightsObservationTask = Task { [syncRuntime, weightManager] in
            do {
                for try await _ in weightManager.observe().dropFirst() {
                    try await syncRuntime.flush()
                }
            }
            catch {
                Logger.weightMonitorSync.error("Failed to flush sync outbox: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
