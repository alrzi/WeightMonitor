//
//  Project.swift
//  WeightHistory
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

let project = Project(
    name: "WeightMonitorFeatureWeightHistory",
    targets: [
        .target(
            name: "WeightMonitorFeatureWeightHistory",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.alrzi.WeightMonitorFeatureWeightHistory",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**/*.swift"],
            resources: ["Resources/**/*.xcstrings"],
            dependencies: [
                .project(target: "WeightMonitorDomain", path: "../../Domain"),
                .project(target: "WeightMonitorUIComponents", path: "../../UIComponents"),
            ]
        ),

        .target(
            name: "WeightMonitorFeatureWeightHistoryTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alrzi.WeightMonitorFeatureWeightHistoryTests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**/*.swift"],
            dependencies: [
                .target(name: "WeightMonitorFeatureWeightHistory")
            ]
        ),
    ]
)
