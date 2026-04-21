//  WeightCreation.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum WeightCreationModuleName: String, CaseIterable {
    case WeightCreation
}

extension WeightCreationModuleName {
    var targets: [Target] {
        switch self {
        case .WeightCreation:
            Target.module(
                name: rawValue,
                product: .framework,
                hasTests: false,
                dependencies: [
                    TargetDependency.module(.Domain),
                    TargetDependency.module(.UIComponents),
                ]
            )
        }
    }
}
