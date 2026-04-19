//
//  Target.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

extension Target {
    static func common(
        name: String,
        product: Product,
        deployment: DeploymentTargets = .iOS("17.0"),
        infoPlist: InfoPlist? = .default,
        resources: ResourceFileElements = .resources(["Resources/**/*"]),
        @ArrayBuilder<TargetDependency> dependencies: () -> [TargetDependency],
    ) -> Target {
        let isTest = product == .unitTests
        return .target(
            name: name,
            destinations: .iOS,
            product: product,
            bundleId: "com.alrzi.\(name)",
            deploymentTargets: deployment,
            infoPlist: infoPlist,
            sources: isTest ? ["Tests/**/*.swift"] : ["Sources/**/*.swift"],
            resources: resources,
            dependencies: dependencies()
        )
    }
}

extension TargetDependency {
    public static func module(_ module: WeightMonitor) -> TargetDependency {
        .project(target: module.rawValue, path: module.projectPath)
    }
}
