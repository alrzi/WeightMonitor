//
//  WeightUnitManager.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation
import WaAsyncExtensions

public protocol WeightUnitManaging: Sendable {
    associatedtype WeightUnitObservation: AsyncSequence where WeightUnitObservation.Element == WeightUnit

    var weightUnitSequence: WeightUnitObservation { get }
    var lastSelectedWeightUnit: WeightUnit { get }

    func set(unit: WeightUnit) async
}

final class WeightUnitManager: WeightUnitManaging {
    private let weightUnitDataStorage: WeightUnitDataStorage

    private let mutableWeightUnit: ObservableActor<WeightUnit>
    var weightUnitSequence: ReadOnlyObservableWrapper<WeightUnit> { mutableWeightUnit.readOnly() }

    var lastSelectedWeightUnit: WeightUnit { weightUnitDataStorage.weightUnit }

    init(weightUnitDataStorage: WeightUnitDataStorage) {
        self.weightUnitDataStorage = weightUnitDataStorage

        mutableWeightUnit = .init(weightUnitDataStorage.weightUnit)
    }

    func set(unit: WeightUnit) async {
        await mutableWeightUnit.set(value: unit)
        weightUnitDataStorage.weightUnit = unit
    }
}
