//
//  WeightHistory.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum WeightHistoryModuleName: String, CaseIterable {
    case WeightHistory
}

extension WeightHistoryModuleName {
    var targets: [Target] {
        switch self {
        case .WeightHistory:
            Target.module(
                name: rawValue,
                dependencies: .build {
                    TargetDependency.module(.Domain)
                    TargetDependency.module(.UIComponents)
                }
            )
        }
    }
}
