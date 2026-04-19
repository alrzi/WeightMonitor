//
//  Domain.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum DomainModuleName: String, CaseIterable {
    case Domain
    case DomainTests
}

extension DomainModuleName {
    var target: Target {
        switch self {
        case .Domain:
            .common(
                name: rawValue,
                product: .staticFramework,
                dependencies: {
                    TargetDependency.external(.Swinject)
                    TargetDependency.external(.AsyncExtensions)
                }
            )
        case .DomainTests:
            .common(
                name: rawValue,
                product: .unitTests,
                dependencies: {
                    TargetDependency.target(name: Self.Domain.rawValue)
                }
            )
        }
    }
}
