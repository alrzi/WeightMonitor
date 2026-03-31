//
//  WeightUnit.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation

public enum WeightUnit: String, Decodable, Sendable {
    case metric
    case imperial

    public var isMetric: Bool {
        switch self {
        case .metric: true
        case .imperial: false
        }
    }    
}
