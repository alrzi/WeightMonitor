//
import WeightMonitorUIComponents
//  WeightMonitorModulesAssembly.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import Swinject
import WeigthMonitorDomain

public final class WeightMonitorModulesAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(WeightCreationFactory.self) { r in
            WeightCreationFactory(
                weightManager: r.resolve(WeightManaging.self)!,
                weightUnitManager: r.resolve((any WeightUnitManaging).self)!
            )
        }

        container.register(WeightHistoryFactory.self) { r in
            WeightHistoryFactory(
                weightManager: r.resolve(WeightManaging.self)!,
                weightUnitManager: r.resolve((any WeightUnitManaging).self)!
            )
        }
    }
}
