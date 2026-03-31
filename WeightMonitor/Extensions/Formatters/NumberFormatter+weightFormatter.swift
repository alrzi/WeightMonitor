//
//  NumberFormatter+weightFormatter.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

extension NumberFormatter {
    static var weightFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.locale = Locale.current
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        f.usesGroupingSeparator = true
        return f
    }

    static var dotOnlyNumberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.decimalSeparator = "."
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        return f
    }
}
