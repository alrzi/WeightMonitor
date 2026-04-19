//
//  DomainAssembly.swift
//  Domain
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import Swinject

public final class DomainAssembly: Assembly {
    public init() { }

    public func assemble(container: Container) {
        container.register((any WeightUnitManaging).self) { r in
            WeightUnitManager(
                weightUnitDataStorage: r.resolve(WeightUnitDataStorage.self)!
            )
        }
        .inObjectScope(.container)

        container.register(WeightManaging.self) { r in
            WeightManager(
                weightRepository: r.resolve(WeightRepositoryProtocol.self)!
            )
        }
        .inObjectScope(.container)
    }
}
