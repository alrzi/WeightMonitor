//
//  WeightMonitorModulesAssembly.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Domain
import Foundation
import Swinject
import UIComponents
import WeightCreation
import WeightHistory

public final class WeightMonitorModulesAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(WeightCreationFactory.self) { resolver in
            WeightCreationFactory(
                weightManager: resolver.resolve(WeightManaging.self)!,
                weightUnitManager: resolver.resolve((any WeightUnitManaging).self)!
            )
        }

        container.register(WeightHistoryFactory.self) { resolver in
            WeightHistoryFactory(
                weightManager: resolver.resolve(WeightManaging.self)!,
                weightUnitManager: resolver.resolve((any WeightUnitManaging).self)!
            )
        }
    }
}
