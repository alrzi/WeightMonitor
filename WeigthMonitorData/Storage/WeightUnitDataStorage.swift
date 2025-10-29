//
//  WeightUnitDataStorage.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import DataStorage
import WeigthMonitorDomain

extension WeightUnitDataStorage where Self: DataStorageProtocol {
    var weightUnit: WeightUnit {
        get {
            guard
                let rawValue: String = getValue(key: Key.weightUnit, storage: .default),
                let weightUnit = WeightUnit(rawValue: rawValue)
            else {
                return .metric
            }

            return weightUnit
        }
        set {
            setValue(key: Key.weightUnit, value: newValue.rawValue, storage: .default)
        }
    }
}

extension DataStorage: WeightUnitDataStorage { }

private enum Key: String, DataStorageKey {
    case weightUnit = "weightUnitDataStorage.weightUnit"
}
