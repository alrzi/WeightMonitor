//
//  WeightDifferentCalculator.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.05.2023.
//

import Foundation

protocol WeightDifferentCalculatorProtocol {
    func addWeightDifference(to weightRecords: [Weight]) -> [Weight]
}

struct WeightDifferentCalculator: WeightDifferentCalculatorProtocol {
    /// Function to update an array of weight records
    func addWeightDifference(to weightRecords: [Weight]) -> [Weight] {
        var updatedRecords = updateWeightDifferences(records: weightRecords)
        updatedRecords = setLastRecordWeightDifferenceToNil(records: updatedRecords)
        return updatedRecords
    }
    
    /// Function to update the weight differences of an array of weight records
    func updateWeightDifferences(records: [Weight]) -> [Weight] {
        return records.enumerated().map { (index, record) in
            // • index is the index of the current element in the records array.
            // • records.count is the total number of elements in the records array.
            // • records.count - 1 is the index of the last element in the records array.
            // • index < records.count - 1 is a condition that checks if the current element is not the last element in the array.
            // • If the condition is true, then records[index+1] is returned. This is the next element in the array after the current element.
            // • If the condition is false, then nil is returned. This means that there is no next element in the array after the current element.
            let nextRecord = index < records.count - 1 ? records[index+1] : nil
            
            return updateWeightDifference(record: record, nextRecord: nextRecord)
        }
    }
    
    /// Function to update the weight difference of a weight record
    func updateWeightDifference(record: Weight, nextRecord: Weight?) -> Weight {
        if let nextRecord {
            let massDifference = record.mass - nextRecord.mass
            
            return Weight(id: record.id, createdAt: record.createdAt, mass: record.mass, massDifference: massDifference)
        }
        else {
            return Weight(id: record.id, createdAt: record.createdAt, mass: record.mass, massDifference: nil)
        }
    }
    
    // Function to set the weight difference of the last record to nil
    func setLastRecordWeightDifferenceToNil(records: [Weight]) -> [Weight] {
        var updatedRecords = records
        if let lastRecord = updatedRecords.last {
            updatedRecords[updatedRecords.count - 1] = Weight(id: lastRecord.id, createdAt: lastRecord.createdAt, mass: lastRecord.mass, massDifference: nil)
        }
        return updatedRecords
    }
}
