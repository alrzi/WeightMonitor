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
                destinations: [.iPhone, .appleWatch],
                deploymentTargets: .multiplatform(iOS: "17.0", watchOS: "10.0"),
                testDeploymentTargets: .iOS("17.0"),
                hasTests: true,
                resources: [],
                dependencies: [
                    TargetDependency.module(.Domain),
                    TargetDependency.module(.Sync),
                    TargetDependency.external(.GRDB),
                    TargetDependency.external(.KeyValueStorage),
                    TargetDependency.external(.Swinject),
                ],
                testDependencies: [
                    TargetDependency.external(.GRDB),
                    TargetDependency.module(.Domain),
                    TargetDependency.module(.Sync),
                ]
            )
        }
    }
}
