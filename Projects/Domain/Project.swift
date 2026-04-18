//
//  Project.swift
//  Domain
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

let project = Project(
    name: "WeightMonitorDomain",
    packages: [
        .remote(url: "https://github.com/Swinject/Swinject.git", requirement: .upToNextMajor(from: "2.8.0")),
        .remote(url: "https://github.com/alrzi/AsyncExtensions.git", requirement: .branch("main")),
    ],
    targets: [
        .target(
            name: "WeightMonitorDomain",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.alrzi.WeightMonitorDomain",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**/*.swift"],
            dependencies: [
                .package(product: "Swinject"),
                .package(product: "AsyncExtensions"),
            ]
        ),

        .target(
            name: "WeightMonitorDomainTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alrzi.WeightMonitorDomainTests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**/*.swift"],
            dependencies: [
                .target(name: "WeightMonitorDomain")
            ]
        ),
    ]
)
