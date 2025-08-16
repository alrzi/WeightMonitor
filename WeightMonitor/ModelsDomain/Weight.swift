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
    let massDifference: Double?
    
    init(
        id: String = UUID().uuidString,
        createdAt: Date,
        mass: Measurement<UnitMass>,
        massDifference: Double? = nil
    ) {
        self.createdAt = createdAt
        self.mass = mass
        self.massDifference = massDifference
        self.id = id
    }
}

extension Weight {
    func withMassUnitUpdated(to newUnit: UnitMass) -> Weight {
        Weight(
            id: id,
            createdAt: createdAt,
            mass: mass.converted(to: newUnit),
            massDifference: massDifference
        )
    }
}
