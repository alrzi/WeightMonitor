import Foundation
import Sync

final class SyncResourceRegistry {
    // MARK: - Private properties

    private let resourcesByDataType: [SyncDataType: any SyncResource]

    // MARK: - Lifecycle

    init(resources: [any SyncResource]) {
        var resourcesByDataType: [SyncDataType: any SyncResource] = [:]

        for resource in resources {
            precondition(
                resourcesByDataType[resource.dataType] == nil,
                "Duplicate sync resource for '\(resource.dataType.rawValue)'"
            )

            resourcesByDataType[resource.dataType] = resource
        }

        self.resourcesByDataType = resourcesByDataType
    }

    // MARK: - Public methods

    func apply(_ payload: SyncPayload) async throws -> Bool {
        guard let resource = resourcesByDataType[payload.dataType] else {
            preconditionFailure(
                "Missing sync resource for '\(payload.dataType.rawValue)'"
            )
        }

        return try await resource.apply(payload)
    }
}
