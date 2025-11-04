//
//  Locale+unitMass.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 26.10.2025.
//

import Foundation

extension Locale {
    var unitMass: UnitMass {
        switch measurementSystem {
        case .metric: .kilograms
        case .uk, .us: .pounds
        default: .kilograms
        }
    }
}
