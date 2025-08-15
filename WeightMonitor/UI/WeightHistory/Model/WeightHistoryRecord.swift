//
//  File.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.05.2023.
//

import Foundation

struct WeightRecord: Equatable {
    let identifier: String
    let date: Date
    let weight: Double
    let weightDifference: Double?
    
    init(
        id: String = UUID().uuidString,
        date: Date,
        weight: Double,
        weightDifference: Double? = nil
    ) {
        self.date = date
        self.weight = weight
        self.weightDifference = weightDifference
        self.identifier = id
    }
}
