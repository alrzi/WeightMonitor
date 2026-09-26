//
//  WeightMonitorDataAssembly.swift
//  WeightMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Domain
import Foundation
import KeyValueStorage
import Swinject
import Sync

public final class WeightMonitorDataAssembly: Assembly {
    private let poolProviderGRDB: GRDBPoolProvider

    public init(poolProviderGRDB: GRDBPoolProvider) {
        self.poolProviderGRDB = poolProviderGRDB
    }

    public func assemble(container: Container) {
        container.register(WeightRepositoryProtocol.self) { [poolProviderGRDB] resolver in
            WeightRepository(
                dbPool: poolProviderGRDB.db,
                syncResource: resolver.resolve(GRDBSyncResource<WeightDB>.self)!
            )
        }
        .inObjectScope(.container)

        container.register((any SyncOutboxStore).self) { [poolProviderGRDB] _ in
            GRDBSyncOutboxStore(dbPool: poolProviderGRDB.db)
        }
        .inObjectScope(.container)

        container.register(GRDBSyncResource<WeightDB>.self) { [poolProviderGRDB] _ in
            GRDBSyncResource<WeightDB>(dbPool: poolProviderGRDB.db)
        }
        .inObjectScope(.container)

        container.register((any SyncResource).self) { resolver in
            resolver.resolve(GRDBSyncResource<WeightDB>.self)!
        }
        .inObjectScope(.container)

        // MARK: - KeyValueStorage
        container.register(WeightUnitDataStorage.self) { _ in UserDefaults.live }
    }
}
