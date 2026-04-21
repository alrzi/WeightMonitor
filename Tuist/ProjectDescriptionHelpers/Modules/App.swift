//  App.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

enum AppModuleName: String, CaseIterable {
    case App
}

extension AppModuleName {
    var targets: [Target] {
        switch self {
        case .App:
            Target.module(
                name: rawValue,
                product: .app,
                infoPlist: .file(path: .relativeToManifest("Info.plist")),
                dependencies: [
                    TargetDependency.module(.Data),
                    TargetDependency.module(.Domain),
                    TargetDependency.module(.UIComponents),
                    TargetDependency.module(.WeightHistory),
                    TargetDependency.module(.WeightCreation),
                ]
            )
        }
    }
}
