//  Target.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 19.04.2026.
//

import ProjectDescription

extension Target {
    static func module(
        name: String,
        product: Product,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        infoPlist: InfoPlist = .default,
        hasTests: Bool = true,
        resources: ResourceFileElements = .resources(["Resources/**"]),
        dependencies: [TargetDependency] = [],
        testDependencies: [TargetDependency] = []
    ) -> [Target] {
        let mainTarget = Target.target(
            name: name,
            destinations: .iOS,
            product: product,
            bundleId: "com.alrzi.\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: ["Sources/**/*.swift"],
            resources: resources,
            dependencies: dependencies
        )

        if !hasTests {
            return [mainTarget]
        }

        let testTarget = Target.target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alrzi.\(name)Tests",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: ["Tests/**/*.swift"],
            dependencies: [.target(name: name)] + testDependencies
        )

        return [mainTarget, testTarget]
    }
}

extension TargetDependency {
    public static func module(_ module: WeightMonitor) -> TargetDependency {
        .project(target: module.rawValue, path: module.projectPath)
    }
}
