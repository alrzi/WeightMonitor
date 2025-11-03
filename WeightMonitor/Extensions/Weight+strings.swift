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
        MassFormatter
            .twoDigits
            .string(
                fromValue: Measurement(value: mass, unit: .kilograms)
                    .converted(to: unit.toUnitMass())
                    .value,
                unit: unit.toUnit()
            )
    }

    func massDifferenceFormatted(to unit: WeightUnit) -> String? {
        massDifference.map {
            MassFormatter
                .twoDigits
                .string(
                    fromValue: Measurement(value: $0, unit: .kilograms)
                        .converted(to: unit.toUnitMass())
                        .value,
                    unit: unit.toUnit()
                )
        }
    }

    var createdAtFormatted: String {
        createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated))
    }
}
