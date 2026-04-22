//  Data.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum DataModuleName: String, CaseIterable {
    case Data
}

extension DataModuleName {
    var targets: [Target] {
        switch self {
        case .Data:
            Target.module(
                name: rawValue,
                product: .staticFramework,
                hasTests: false,
                resources: [],
                dependencies: [
                    TargetDependency.module(.Domain),
                    TargetDependency.external(.GRDB),
                    TargetDependency.external(.KeyValueStorage),
                    TargetDependency.external(.Swinject),
                ]
            )
        }
    }
}
