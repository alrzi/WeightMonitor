//
//  WeightHistoryCellViewModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation

final class WeightHistoryCellViewModel {
    private let weight: Weight
    private let currentWeightUnit: UnitMass
    private let stringFormatter: StringFormatter
    
    init(
        weight: Weight,
        weightUnitService: WeightSystem = WeightSystem.shared,
        stringFormatter: StringFormatter = StringFormatter()
    ) {
        self.weight = weight
        self.currentWeightUnit = weightUnitService.currentUnit
        self.stringFormatter = stringFormatter
    }
        
    var weightFormatted: String {
        weight.mass.formatted(.mass)
    }
    
    var massDifferenceFormatted: String? {
        weight.massDifference.map { $0.formatted(.mass) }
    }
    
    var createdAtFormatted: String {
        weight.createdAt.formatted(date: .abbreviated, time: .omitted)
    }
    
    var currentUnitName: String {
        stringFormatter.getUnitSystemName(for: currentWeightUnit)
    }
    
    var isSwitchOn: Bool {
        switch currentWeightUnit {
        case .kilograms:
            return true
        case .pounds:
            return false
        default:
            return false
        }
    }
}

extension FormatStyle where Self == Measurement<UnitMass>.FormatStyle {
    static var mass: Self {
        .measurement(
            width: .abbreviated,
            usage: .personWeight,
            numberFormatStyle: .number.precision(.fractionLength(1)).sign(strategy: .always(includingZero: true))
        )
    }
}
