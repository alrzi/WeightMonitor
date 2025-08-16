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
        weight.mass.formatted(.mass(style: .withOneComma))
    }
    
    var massDifferenceFormatted: String? {
        weight.massDifference.map { $0.formatted(.mass(style: .withOneComma.sign(strategy: .always(includingZero: true)))) }
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

private extension FormatStyle where Self == Measurement<UnitMass>.FormatStyle {
    static func mass(style: FloatingPointFormatStyle<Double>) -> Self {
        .measurement(
            width: .abbreviated,
            usage: .personWeight,
            numberFormatStyle: style
        )
    }
}

private extension FloatingPointFormatStyle<Double> {
    static var withOneComma: Self {
        .number.precision(.fractionLength(1))
    }
}
