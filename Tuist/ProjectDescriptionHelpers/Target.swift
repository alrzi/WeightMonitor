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
        bundleId: String? = nil,
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        testDeploymentTargets: DeploymentTargets? = nil,
        infoPlist: InfoPlist = .default,
        hasTests: Bool = true,
        sources: SourceFilesList = ["Sources/**/*.swift"],
        resources: ResourceFileElements = .resources(["Resources/**"]),
        dependencies: [TargetDependency] = [],
        testDependencies: [TargetDependency] = []
    ) -> [Target] {
        let mainTarget = Target.target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleId ?? "com.alrzi.\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
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
            deploymentTargets: testDeploymentTargets ?? deploymentTargets,
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

    public static var syncImplementation: TargetDependency {
        .project(target: "SyncImplementation", path: WeightMonitor.Sync.projectPath)
    }
}
