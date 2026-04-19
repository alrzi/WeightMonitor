//
//  WeightCreation.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum WeightCreationModuleName: String, CaseIterable {
    case WeightCreation
    case WeightCreationTests
}

extension WeightCreationModuleName {
    var target: Target {
        switch self {
        case .WeightCreation:
            .common(
                name: rawValue,
                product: .framework,
                dependencies: {
                    TargetDependency.module(.Domain)
                    TargetDependency.module(.UIComponents)
                },
            )
        case .WeightCreationTests:
            .common(
                name: rawValue,
                product: .unitTests,
                dependencies: {
                    TargetDependency.target(name: Self.WeightCreation.rawValue)
                }
            )
        }
    }
}
