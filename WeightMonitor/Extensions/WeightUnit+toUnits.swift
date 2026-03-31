//
//  WeightUnit+toUnits.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation
import WeigthMonitorDomain

extension WeightUnit {
    func toUnitMass() -> UnitMass {
        switch self {
        case .metric: .kilograms
        case .imperial: .pounds
        @unknown default: .kilograms
        }
    }
}
