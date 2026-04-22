//
//  Measurement+formattedNarrow.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 01.12.2025.
//

import Foundation

public extension Measurement where UnitType == UnitMass {
    func formattedNarrow(asProvided: Bool = true, fractionRange: ClosedRange<Int> = 0...2, showSign: Bool = false) -> String {
        var numberStyle = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(fractionRange))

        if showSign {
            numberStyle = numberStyle.sign(strategy: .always(includingZero: false))
        }

        return formatted(
            .measurement(
                width: .narrow,
                usage: asProvided ? .asProvided : .general,
                numberFormatStyle: numberStyle
            )
        )
    }
}
