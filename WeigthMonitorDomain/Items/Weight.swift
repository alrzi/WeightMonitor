//
//  Weight.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.05.2023.
//

import Foundation

public struct Weight: Equatable, Identifiable, Sendable {
    public let id: Int64?
    public let createdAt: Date
    public let mass: Double
    public let massDifference: Double?

    public init(
        id: Int64? = nil,
        createdAt: Date,
        mass: Double,
        massDifference: Double? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.mass = mass
        self.massDifference = massDifference
    }

    public func difference(with other: Self) -> Self {
        Weight(
            id: id,
            createdAt: createdAt,
            mass: mass,
            massDifference: mass - other.mass
        )
    }
}

public extension Weight {
    func toCursorIfPossible() -> WeightCursor? {
        id.map { .init(createdAt: createdAt, id: $0) }
    }
}

extension Weight {
    public var weightMeasurement: Measurement<UnitMass> {
        Measurement(value: mass, unit: .kilograms)
    }

    public var weightDifferenceMeasurement: Measurement<UnitMass>? {
        if let massDifference {
            Measurement(value: massDifference, unit: .kilograms)
        }
        else {
            nil
        }
    }
}
