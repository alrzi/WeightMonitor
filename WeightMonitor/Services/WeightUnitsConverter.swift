//
//  WeightUnitsConverter.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.05.2023.
//

import Foundation


struct WeightUnitConverter {
    func convertUnitsOfWeight(to currentUnit: UnitMass, _ record: WeightRecord) -> WeightRecord {
        let newUnitWeight = Measurement(value: record.weight, unit: UnitMass.kilograms).converted(to: currentUnit).value
                       
        let newUnitWeightChange =  Measurement(value: record.weightDifference ?? 0, unit: UnitMass.kilograms).converted(to: currentUnit).value
                        
        return WeightRecord(id: record.identifier, date: record.date, weight: newUnitWeight, weightDifference: newUnitWeightChange)
    }
}
