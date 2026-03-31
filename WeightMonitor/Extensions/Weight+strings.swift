//
//  Weight+localized.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation
import WeigthMonitorDomain

extension Weight {
    func weightFormatted(to unit: WeightUnit) -> String {
        mass.formattedWeight(to: unit)
    }

    func massDifferenceFormatted(to unit: WeightUnit) -> String? {
        massDifference.map { $0.formattedWeight(to: unit, showSign: true) }
    }

    var createdAtFormatted: String {
        createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated))
    }
}

private extension Double {
    func formattedWeight(to unit: WeightUnit, showSign: Bool = false) -> String {
        Measurement(value: self, unit: .kilograms)
            .converted(to: unit.toUnitMass())
            .formattedNarrow(asProvided: true, fractionRange: 0...2, showSign: showSign)
    }
}
