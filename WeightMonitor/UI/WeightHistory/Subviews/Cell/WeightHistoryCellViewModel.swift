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
        weight.mass.formatted(.mass(style: .withOneComma, locale: locale))
    }
    
    var massDifferenceFormatted: String? {
        weight.massDifference.map { $0.formatted(.mass(style: .withOneComma.sign(strategy: .always(includingZero: true)), locale: locale)) }
    }
    
    var createdAtFormatted: String {
        weight.createdAt.formatted(date: .abbreviated, time: .omitted)
    }
    
    var currentUnitName: String {
        stringFormatter.getUnitSystemName(for: currentWeightUnit)
    }
    
    var isSwitchOn: Bool {
        switch currentWeightUnit {
        case .kilograms: true
        case .pounds: false
        default: false
        }
    }
    
    private var locale: Locale {
        switch currentWeightUnit {
        case .pounds: Locale(identifier: "en_US")
        default: Locale(identifier: "ru_RU")
        }
    }
}

private extension FormatStyle where Self == Measurement<UnitMass>.FormatStyle {
    static func mass(style: FloatingPointFormatStyle<Double>, locale: Locale) -> Self {
        Measurement<UnitMass>.FormatStyle(
            width: .abbreviated,
            locale: locale,
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
