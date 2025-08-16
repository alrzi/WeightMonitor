//
//  UserInput.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 07.05.2023.
//

import Foundation

struct UserInput {
    var date: Date?
    var weight: Double?
    
    var isPossibleToAddWeight: Bool {
        !date.isNil && !weight.isNil
    }
    
    func createRecord(unitMass: UnitMass) -> Weight? {
        guard let date, let weight else { return nil }
        
        return Weight(createdAt: date, mass: .init(value: weight, unit: unitMass))
    }
}
