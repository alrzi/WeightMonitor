//
//  Project.swift
//  Data
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

let project = Project(
    name: "WeightMonitorData",
    packages: [
        .remote(url: "https://github.com/groue/GRDB.swift.git", requirement: .upToNextMajor(from: "6.29.0")),
        .remote(url: "https://github.com/alrzi/KeyValueStorage.git", requirement: .branch("main")),
        .remote(url: "https://github.com/Swinject/Swinject.git", requirement: .upToNextMajor(from: "2.8.0")),
    ],
    targets: [
        .target(
            name: "WeightMonitorData",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.alrzi.WeightMonitorData",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**/*.swift"],
            dependencies: [
                .project(target: "WeightMonitorDomain", path: "../Domain"),
                .package(product: "GRDB"),
                .package(product: "KeyValueStorage"),
                .package(product: "Swinject"),
            ]
        ),

        .target(
            name: "WeightMonitorDataTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alrzi.WeightMonitorDataTests",
            deploymentTargets: .iOS("16.0"),
            sources: ["Tests/**/*.swift"],
            dependencies: [
                .target(name: "WeightMonitorData")
            ]
        ),
    ]
)
