//
//  StringFormatter.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 04.05.2023.
//

import Foundation

struct StringFormatter {
    private let weightFormatter: NumberFormatter = Formatters.numberFormatter       
    
    func getUnitSystemName(for unit: UnitMass) -> String {
        let massUnitSymbols = [
            "kg": String(localized: "weightHistory.unitSystem.metric", table: "WeightList"),
            "lb": String(localized: "weightHistory.unitSystem.imperial", table: "WeightList")
        ]
        return massUnitSymbols[unit.symbol] ?? String(localized: "weightHistory.unitSystem.unknown", table: "WeightList")
    }
    
    func format(text: String, for unit: UnitMass) -> String {
        var formattedText = ""
        let inputWithoutCommas = text.replacingOccurrences(of: ",", with: "")
        let inputNumber = Double(inputWithoutCommas) ?? 0.0
        
        if unit.symbol == UnitMass.kilograms.symbol {
            if inputNumber >= 100 {
                let wholeNumber = Int(inputNumber / 10)
                let decimalNumber = inputNumber.truncatingRemainder(dividingBy: 10)
                formattedText = "\(wholeNumber),\(Int(decimalNumber))"
            } else {
                formattedText = "\(Int(inputNumber))"
            }
        } else if unit.symbol == UnitMass.pounds.symbol {
            if inputNumber >= 1000 {
                let wholeNumber = Int(inputNumber / 10)
                let decimalNumber = inputNumber.truncatingRemainder(dividingBy: 10)
                formattedText = "\(wholeNumber),\(Int(decimalNumber))"
            } else if inputNumber >= 10 {
                formattedText = "\(Int(inputNumber))"
            } else {
                formattedText = "\(Int(inputNumber))"
            }
        } else {
            return formattedText
        }
        
        return formattedText
    }
    
    func formatStringToDouble(_ string: String) -> Double? {        
        if let number = weightFormatter.number(from: string) {
            return number.doubleValue
        } else {
            return nil
        }
    }
}
