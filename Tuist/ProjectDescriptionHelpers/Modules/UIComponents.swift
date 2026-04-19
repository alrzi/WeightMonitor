//
//  UIComponents.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum UIComponentsModuleName: String, CaseIterable {
    case UIComponents
    case UIComponentsTests
}

extension UIComponentsModuleName {
    var target: Target {
        switch self {
        case .UIComponents:
            .common(
                name: rawValue,
                product: .staticFramework,
                dependencies: {
                    TargetDependency.module(.Domain)
                }
            )
        case .UIComponentsTests:
            .common(
                name: rawValue,
                product: .unitTests,
                dependencies: {
                    TargetDependency.target(name: Self.UIComponents.rawValue)
                }
            )
        }
    }
}
