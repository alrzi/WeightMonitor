//
//  MassFormatter+twoDigits.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

extension MassFormatter {
    static var twoDigits: MassFormatter {
        let formatter = MassFormatter()
        formatter.numberFormatter.locale = .autoupdatingCurrent
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter
    }
}
