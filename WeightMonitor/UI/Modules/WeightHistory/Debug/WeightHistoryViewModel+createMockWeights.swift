//
import WeightMonitorUIComponents
//  WeightHistoryViewModel+createMockWeights.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.11.2025.
//

import Foundation
import WeigthMonitorDomain

#if DEBUG
extension WeightHistoryViewModel {
    static func createMockWeights(weightManager: WeightManaging) {
        Task {
            await withTaskGroup { group in
                Weight
                    .mockYearlyWeights(startMass: 78.0, variation: 0.25, seed: 42)
                    .forEach { weight in
                        group.addTask {
                            try? await weightManager.create(weight: weight)
                        }
                    }
            }
        }
    }
}
#endif
