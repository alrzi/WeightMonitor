//
import WeightMonitorUIComponents
//  WeightCreationFactory.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import Foundation
import WeigthMonitorDomain

public struct WeightCreationFactory {
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
    public func makeViewModel(
        input: WeightCreationInput,
        onCompletion: @escaping @MainActor @Sendable () -> Void
    ) -> WeightCreationViewModel {
        WeightCreationViewModel(
            weightManager: weightManager,
            weightUnitManager: weightUnitManager,
            invalidComponentManager: InvalidComponentManager(),
            input: input,
            onCompletion: onCompletion
        )
    }
}
