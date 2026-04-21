//  UIComponents.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum UIComponentsModuleName: String, CaseIterable {
    case UIComponents
}

extension UIComponentsModuleName {
    var targets: [Target] {
        switch self {
        case .UIComponents:
            Target.module(
                name: rawValue,
                product: .staticFramework,
                dependencies: [
                    TargetDependency.module(.Domain)
                ]
            )
        }
    }
}
