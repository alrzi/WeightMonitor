//  Domain.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum DomainModuleName: String, CaseIterable {
    case Domain
}

extension DomainModuleName {
    var targets: [Target] {
        switch self {
        case .Domain:
            Target.module(
                name: rawValue,
                product: .staticFramework,
                destinations: [.iPhone, .appleWatch],
                deploymentTargets: .multiplatform(iOS: "17.0", watchOS: "10.0"),
                testDeploymentTargets: .iOS("17.0"),
                hasTests: false,
                resources: [],
                dependencies: [
                    TargetDependency.external(.Swinject),
                    TargetDependency.external(.AsyncExtensions),
                ]
            )
        }
    }
}
