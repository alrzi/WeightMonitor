//
//  WeightUnit.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation

protocol WeightUnitServiceProtocol {
    var currentUnit: UnitMass { get set }
    func getCurrentUnit() -> UnitMass
}

final class WeightSystem: WeightUnitServiceProtocol {
    static let shared = WeightSystem()
    
    private init() {}
    
    private let userDefaults = UserDefaults.standard
  
    var currentUnit = UnitMass.kilograms {
        didSet {
            updateCurrentUnit(newUnit: currentUnit)
        }
    }
    
    func getCurrentUnit() -> UnitMass {
        guard let encodedData = UserDefaults.standard.data(forKey: Keys.WeightUnit.rawValue) else  {
            return UnitMass.kilograms
        }
        if let unitMass = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UnitMass.self, from: encodedData) {
            return unitMass
        } else {
            return UnitMass.kilograms
        }
    }
        
    // Private
    private enum Keys: String {
        case WeightUnit
    }
    
    private func updateCurrentUnit(newUnit: UnitMass) {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: newUnit, requiringSecureCoding: false) {        
            UserDefaults.standard.set(encodedData, forKey: Keys.WeightUnit.rawValue)
        }
    }
}
