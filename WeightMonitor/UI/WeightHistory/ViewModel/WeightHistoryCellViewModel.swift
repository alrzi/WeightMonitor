//
//  WeightHistoryCellViewModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation

final class WeightHistoryCellViewModel {
    private let weightRecord: WeightRecord
    private let weightUnitService: WeightSystem
    private let stringFormatter: StringFormatter
    
    init(weightRecord: WeightRecord,
         weightUnitService: WeightSystem = WeightSystem.shared,
         stringFormatter: StringFormatter = StringFormatter(formatters: Formatters())) {
        
        self.weightRecord = weightRecord
        self.weightUnitService = weightUnitService
        self.stringFormatter = stringFormatter
    }
        
    var weight: String {
        let weight = stringFormatter.convertWeightToString(weightRecord.weight, for: weightUnitService.currentUnit)
        return weight
    }
    
    var weightDifference: String {
        let weightDiff = stringFormatter.convertWeightChangeToString(
            change: weightRecord.weightDifference,
            selectedUnitType: weightUnitService.currentUnit
        )
        return weightDiff
    }
    
    var date: String {
        let date = stringFormatter.formatDate(date: weightRecord.date)
        return date
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
