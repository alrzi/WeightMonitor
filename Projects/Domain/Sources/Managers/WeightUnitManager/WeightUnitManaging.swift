//
//  WeightUnitManaging.swift
//  WeigthMonitorDomain
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

public protocol WeightUnitManaging: Sendable {
    associatedtype WeightUnitObservation: AsyncSequence where WeightUnitObservation.Element == WeightUnit

    var weightUnitSequence: WeightUnitObservation { get }
    var lastSelectedWeightUnit: WeightUnit { get }

    func set(unit: WeightUnit) async
}
