//
//  WeightUnitDataStorage.swift
//  Domain
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation

public protocol WeightUnitDataStorage: AnyObject, Sendable {
    var weightUnit: WeightUnit { get set }
}
