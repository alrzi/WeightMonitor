//
//  Model.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 07.05.2023.
//

import Foundation

// Struct to collect user input data
struct UserInput {
    var date: Date?
    var weight: Double?
    
    var isPossibleToAddWeight: Bool {
        if let date, let weight {
            return true
        } else {
            return false
        }
    }
    
    func createRecord() -> WeightRecord? {
        guard let date, let weight else { return nil }
        return WeightRecord(date: date, weight: weight)
    }
}
