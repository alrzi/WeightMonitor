//
//  WeigthMonitorDataAssembly.swift
//  WeigthMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import Swinject
internal import DataStorage
import WeigthMonitorDomain

public final class WeigthMonitorDataAssembly: Assembly {
    public init() { }

    public func assemble(container: Container) {
        container.register(DataStorage<DataStorageType>.self) { _ in
            DataStorage(
                jsonDecoder: JSONDecoder(),
                jsonEncoder: JSONEncoder(),
                userDefaultsProvider: {
                    switch $0 {
                    case .standart: .standard
                    }
                }
            )
        }
        .inObjectScope(.container)
        .implements((any DataStorageProtocol).self)
        .implements(WeightUnitDataStorage.self)

        container.register(GRDBPoolProvider.self) { _ in
            GRDBPoolProvider()
        }

        container.register(WeigthRepositoryProtocol.self) { r in
            do {
                let dbPool = try r.resolve(GRDBPoolProvider.self)!.createDBPool()

                return WeigthRepository(dbPool: dbPool)
            }
            catch {
                debugPrint(error)

                fatalError()
            }
        }
        .inObjectScope(.container)
    }
}
