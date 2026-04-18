//
//  Bundle+Localized.swift
//  WeightMonitorFeatureWeightHistory
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import Foundation

extension String {
    static func featureLocalized(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }
}
