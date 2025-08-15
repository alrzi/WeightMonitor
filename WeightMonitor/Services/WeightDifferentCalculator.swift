//
//  WeightDifferentCalculator.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.05.2023.
//

import Foundation

protocol WeightDifferentCalculatorProtocol {
    func addWeightDifference(to weightRecords: [WeightRecord]) -> [WeightRecord]
}

struct WeightDifferentCalculator: WeightDifferentCalculatorProtocol {
    /// Function to update an array of weight records
    func addWeightDifference(to weightRecords: [WeightRecord]) -> [WeightRecord] {
        var updatedRecords = updateWeightDifferences(records: weightRecords)
        updatedRecords = setLastRecordWeightDifferenceToNil(records: updatedRecords)
        return updatedRecords
    }
    
    /// Function to update the weight differences of an array of weight records
    func updateWeightDifferences(records: [WeightRecord]) -> [WeightRecord] {
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
    func updateWeightDifference(record: WeightRecord, nextRecord: WeightRecord?) -> WeightRecord {
        if let nextRecord = nextRecord {
            let weightDifference = calculateWeightDifference(record1: record, record2: nextRecord)
            return WeightRecord(id: record.identifier, date: record.date, weight: record.weight, weightDifference: weightDifference)
        } else {
            return WeightRecord(id: record.identifier, date: record.date, weight: record.weight, weightDifference: nil)
        }
    }
    
    /// Function to calculate the weight difference between two weight records
    func calculateWeightDifference(record1: WeightRecord, record2: WeightRecord) -> Double {
        return record1.weight - record2.weight
    }
    
    // Function to set the weight difference of the last record to nil
    func setLastRecordWeightDifferenceToNil(records: [WeightRecord]) -> [WeightRecord] {
        var updatedRecords = records
        if let lastRecord = updatedRecords.last {
            updatedRecords[updatedRecords.count - 1] = WeightRecord(id: lastRecord.identifier, date: lastRecord.date, weight: lastRecord.weight, weightDifference: nil)
        }
        return updatedRecords
    }
}
