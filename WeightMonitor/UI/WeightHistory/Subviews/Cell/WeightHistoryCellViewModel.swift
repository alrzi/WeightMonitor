//
//  WeightHistoryCellViewModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation

final class WeightHistoryCellViewModel {
    private let weight: Weight
    private let weightUnitService: WeightSystem
    private let stringFormatter: StringFormatter
    
    init(
        weight: Weight,
        weightUnitService: WeightSystem = WeightSystem.shared,
        stringFormatter: StringFormatter = StringFormatter(formatters: Formatters())
    ) {
        self.weight = weight
        self.weightUnitService = weightUnitService
        self.stringFormatter = stringFormatter
    }
        
    var weightFormatted: String {
        weight.mass.formatted(.measurement(width: .abbreviated, usage: .personWeight))
    }
    
    var massDifference: String {
        let weightDiff = stringFormatter.convertWeightChangeToString(
            change: weight.massDifference,
            selectedUnitType: weightUnitService.currentUnit
        )
        return weightDiff
    }
    
    var date: String {
        weight.createdAt.formatted(date: .abbreviated, time: .omitted)
    }
    
    var currentUnitName: String {
        stringFormatter.getUnitSystemName(for: weightUnitService.currentUnit)
    }
    
    var isSwitchOn: Bool {
        switch weightUnitService.currentUnit {
        case .kilograms:
            return true
        case .pounds:
            return false
        default:
            return false
        }
    }
}
