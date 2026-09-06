import Foundation
import Sync

final class SyncResourceRegistry {
    // MARK: - Private properties

    private let resources: [any SyncResource]

    // MARK: - Lifecycle

    init(resources: [any SyncResource]) {
        self.resources = resources
    }

    // MARK: - Public methods

    func apply(_ payload: SyncPayload) async throws -> Bool {
        guard let resource = resources.first(where: { $0.dataType == payload.dataType }) else {
            return false
        }

        return try await resource.apply(payload)
    }

    func snapshot() async throws -> SyncSnapshot {
        var payloads: [SyncPayload] = []

        for resource in resources {
            payloads += try await resource.snapshotPayloads()
        }

        return SyncSnapshot(payloads: payloads)
    }
}
