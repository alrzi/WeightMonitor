//
//  Weight.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.05.2023.
//

import Foundation

struct Weight: Equatable, Identifiable {
    let id: String
    let createdAt: Date
    let mass: Measurement<UnitMass>
    let massDifference: Measurement<UnitMass>?
    
    init(
        id: String = UUID().uuidString,
        createdAt: Date,
        mass: Measurement<UnitMass>,
        massDifference: Measurement<UnitMass>? = nil
    ) {
        self.createdAt = createdAt
        self.mass = mass
        self.massDifference = massDifference
        self.id = id
    }
}
