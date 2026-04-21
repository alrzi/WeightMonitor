//
//  DomainAssembly.swift
//  Domain
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import Swinject

public final class DomainAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register((any WeightUnitManaging).self) { resolver in
            WeightUnitManager(
                weightUnitDataStorage: resolver.resolve(WeightUnitDataStorage.self)!
            )
        }
        .inObjectScope(.container)

        container.register(WeightManaging.self) { resolver in
            WeightManager(
                weightRepository: resolver.resolve(WeightRepositoryProtocol.self)!
            )
        }
        .inObjectScope(.container)
    }
}
