//
//  Project.swift
//  UIComponents
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

let project = Project(
    name: "WeightMonitorUIComponents",
    packages: [
        .remote(url: "https://github.com/alrzi/AsyncExtensions.git", requirement: .branch("main"))
    ],
    targets: [
        .target(
            name: "WeightMonitorUIComponents",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.alrzi.WeightMonitorUIComponents",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**/*.swift"]
        ),

        .target(
            name: "WeightMonitorUIComponentsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alrzi.WeightMonitorUIComponentsTests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**/*.swift"],
            dependencies: [
                .target(name: "WeightMonitorUIComponents")
            ]
        ),
    ]
)
