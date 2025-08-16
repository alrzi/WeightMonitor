//
//  StringFormatter.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 04.05.2023.
//

import Foundation

final class StringFormatter {
    private var weightFormatter: NumberFormatter
    private var messurementFormatter: MeasurementFormatter
    
    init(formatters: Formatters) {
        self.weightFormatter = Formatters.numberFormatter
        self.messurementFormatter = Formatters.measurementFormatter
    }
    
    func convertWeightChangeToString(change: Double?, selectedUnitType: UnitMass) -> String {
        let changeString = formatWeight(change)
        let russianTranslation = selectedUnitType.symbol
        return combineNumberWithSymbol(change, change: changeString, symbol: russianTranslation)
    }
    
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
 
// MARK: - Private methods
private extension StringFormatter {
    func formatWeight(_ weight: Double?) -> String {
        guard let weight = weight else { return "" }
        return weightFormatter.string(from: NSNumber(value: weight)) ?? ""
    }
    
    func combineNumberWithSymbol(_ number: Double?, change: String, symbol: String) -> String {
        guard let number = number else { return "" }
        
        if  number > 0 {
            return "+\(change) \(symbol)"
        } else if  number < 0 {
            return "\(change) \(symbol)"
        } else if number == 0 {
            return "\(change) \(symbol)"
        } else {
            return "" 
        }
    }
}
