//
//  WeigthMonitorDataAssembly.swift
//  WeigthMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import Swinject
import KeyValueStorage
import WeigthMonitorDomain

public final class WeigthMonitorDataAssembly: Assembly {
    private let poolProviderGRDB: GRDBPoolProvider

    public init(poolProviderGRDB: GRDBPoolProvider) {
        self.poolProviderGRDB = poolProviderGRDB
    }

    public func assemble(container: Container) {
        container.register(WeigthRepositoryProtocol.self) { [poolProviderGRDB] r in
            WeigthRepository(dbPool: poolProviderGRDB.db)
        }
        .inObjectScope(.container)

        // MARK: - KeyValueStorage
        container.register(WeightUnitDataStorage.self) { _ in UserDefaults.live }
    }
}
