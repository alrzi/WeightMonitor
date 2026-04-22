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

public final class WeightMonitorDataAssembly: Assembly {
    private let poolProviderGRDB: GRDBPoolProvider

    public init(poolProviderGRDB: GRDBPoolProvider) {
        self.poolProviderGRDB = poolProviderGRDB
    }

    public func assemble(container: Container) {
        container.register(WeightRepositoryProtocol.self) { [poolProviderGRDB] _ in
            WeightRepository(dbPool: poolProviderGRDB.db)
        }
        .inObjectScope(.container)

        // MARK: - KeyValueStorage
        container.register(WeightUnitDataStorage.self) { _ in UserDefaults.live }
    }
}
