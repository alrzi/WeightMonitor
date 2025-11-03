//
//  WeightUnitManager.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation
import WaAsyncExtensions

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
