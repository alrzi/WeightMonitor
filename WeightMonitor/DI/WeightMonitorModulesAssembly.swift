//
//  WeightMonitorModulesAssembly.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import Swinject
import WeigthMonitorDomain

public final class WeightMonitorModulesAssembly: Assembly {
    public init() { }

    public func assemble(container: Container) {
        container.register(WeightHistoryAssembly.self) { r in
            WeightHistoryAssembly(
                weightManager: r.resolve(WeightManaging.self)!,
                weightUnitManager: r.resolve((any WeightUnitManaging).self)!,
                weightCreationAssembly: r.resolve(WeightCreationAssembly.self)!,
            )
        }

        container.register(WeightCreationAssembly.self) { r in
            WeightCreationAssembly(
                weightManager: r.resolve(WeightManaging.self)!,
                weightUnitManager: r.resolve((any WeightUnitManaging).self)!,
            )
        }
    }
}
