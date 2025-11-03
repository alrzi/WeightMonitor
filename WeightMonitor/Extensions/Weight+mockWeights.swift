//
//  Weight+mockWeights.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.11.2025.
//

import Foundation
import WeigthMonitorDomain

#if DEBUG
extension Weight {
    static var mockWeights: [Self] {
        (55...90).enumerated().map { index, i in
            Weight(
                createdAt: .now.addingTimeInterval(TimeInterval(-(index * 60 * 60 * 24))),
                mass: Double(i)
            )
        }
    }
}
#endif
