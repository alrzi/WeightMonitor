//
//  WeightHistoryFactory.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import Foundation
import Domain
import UIComponents

public struct WeightHistoryFactory {
    private let weightManager: any WeightManaging
    private let weightUnitManager: any WeightUnitManaging

    public init(
        weightManager: any WeightManaging,
        weightUnitManager: any WeightUnitManaging
    ) {
        self.weightManager = weightManager
        self.weightUnitManager = weightUnitManager
    }

    @MainActor
    public func makeViewModel(router: WeightHistoryRouter) -> WeightHistoryViewModel {
        WeightHistoryViewModel(
            weightManager: weightManager,
            weightUnitManager: weightUnitManager,
            router: router
        )
    }
}
