//
//  WeightUnitDataStorage.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import KeyValueStorage
import WeigthMonitorDomain

extension KeyValueStorageProtocol where Self: WeightUnitDataStorage {
    public var weightUnit: WeightUnit {
        get {
            guard let weightUnit = WeightUnit(rawValue: fetch(Key.self)) else {
                return .metric
            }

            return weightUnit
        }
        set {
            save(newValue.rawValue, for: Key.self)
        }
    }
}

extension UserDefaults: @retroactive WeightUnitDataStorage { }

private enum Key: StorageKey {
    typealias Value = String

    static let name = "weightUnitDataStorage.weightUnit"
    static let defaultValue: String = WeightUnit.metric.rawValue
}
