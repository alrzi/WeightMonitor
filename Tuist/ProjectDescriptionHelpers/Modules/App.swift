//
//  App.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum AppModuleName: String, CaseIterable {
    case App
    case AppTests
}

extension AppModuleName {
    var target: Target {
        switch self {
        case .App:
            .common(
                name: rawValue,
                product: .app,
                infoPlist: .file(path: .relativeToManifest("Info.plist")),
                dependencies: {
                    TargetDependency.module(.Data)
                    TargetDependency.module(.Domain)
                    TargetDependency.module(.UIComponents)
                    TargetDependency.module(.WeightHistory)
                    TargetDependency.module(.WeightCreation)
                },
            )
        case .AppTests:
            .common(
                name: rawValue,
                product: .unitTests,
                dependencies: {
                    TargetDependency.target(name: Self.App.rawValue)
                }
            )
        }
    }
}
