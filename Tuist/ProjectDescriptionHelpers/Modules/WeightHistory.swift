//
//  WeightHistory.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum WeightHistoryModuleName: String, CaseIterable {
    case WeightHistory
    case WeightHistoryTests
}

extension WeightHistoryModuleName {
    var target: Target {
        switch self {
        case .WeightHistory:
            .common(
                name: rawValue,
                product: .framework,
                dependencies: {
                    TargetDependency.module(.Domain)
                    TargetDependency.module(.UIComponents)
                }
            )
        case .WeightHistoryTests:
            .common(
                name: rawValue,
                product: .unitTests,
                dependencies: {
                    TargetDependency.target(name: Self.WeightHistory.rawValue)
                }
            )
        }
    }
}
