//
//  Project.swift
//  WeightCreation
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

let project = Project(
    name: "WeightMonitorFeatureWeightCreation",
    targets: [
        .target(
            name: "WeightMonitorFeatureWeightCreation",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.alrzi.WeightMonitorFeatureWeightCreation",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**/*.swift"],
            dependencies: [
                .project(target: "WeightMonitorDomain", path: "../../Domain"),
                .project(target: "WeightMonitorUIComponents", path: "../../UIComponents"),
            ]
        ),

        .target(
            name: "WeightMonitorFeatureWeightCreationTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alrzi.WeightMonitorFeatureWeightCreationTests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**/*.swift"],
            dependencies: [
                .target(name: "WeightMonitorFeatureWeightCreation")
            ]
        ),
    ]
)
