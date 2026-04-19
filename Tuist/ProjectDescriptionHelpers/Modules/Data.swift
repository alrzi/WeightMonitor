//
//  Data.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum DataModuleName: String, CaseIterable {
    case Data
    case DataTests
}

extension DataModuleName {
    var target: Target {
        switch self {
        case .Data:
            .common(
                name: rawValue,
                product: .staticFramework,
                dependencies: {
                    TargetDependency.module(.Domain)
                    TargetDependency.external(.GRDB)
                    TargetDependency.external(.KeyValueStorage)
                    TargetDependency.external(.Swinject)
                },
            )
        case .DataTests:
            .common(
                name: rawValue,
                product: .unitTests,
                dependencies: {
                    TargetDependency.target(name: Self.Data.rawValue)
                }
            )
        }
    }
}
