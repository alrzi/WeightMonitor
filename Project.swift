//
//  Project.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

let project = Project(
    name: "WeightMonitor",
    packages: [
        .remote(url: "https://github.com/groue/GRDB.swift.git", requirement: .upToNextMajor(from: "6.29.0")),
        .remote(url: "https://github.com/Swinject/Swinject.git", requirement: .upToNextMajor(from: "2.8.0")),
        .remote(url: "https://github.com/alrzi/KeyValueStorage.git", requirement: .branch("main")),
        .remote(url: "https://github.com/alrzi/AsyncExtensions.git", requirement: .branch("main")),
    ],
    targets: [
        .target(
            name: "WeightMonitor",
            destinations: .iOS,
            product: .app,
            bundleId: "com.alrzi.WeightMonitor",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "WeightMonitor/Info.plist",
            sources: ["WeightMonitor/**/*.swift"],
            resources: [
                "WeightMonitor/Assets.xcassets",
                "WeightMonitor/Colors.xcassets",
                "WeightMonitor/Localizable/**/*.xcstrings",
                "WeightMonitor/Base.lproj/LaunchScreen.storyboard",
            ],
            dependencies: [
                .project(target: "WeightMonitorDomain", path: "Projects/Domain"),
                .project(target: "WeightMonitorData", path: "Projects/Data"),
                .project(target: "WeightMonitorUIComponents", path: "Projects/UIComponents"),
                .project(target: "WeightMonitorFeatureWeightCreation", path: "Projects/Features/WeightCreation"),
                .package(product: "Swinject"),
            ]
        ),

        .target(
            name: "WeightMonitorTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alrzi.WeightMonitorTests",
            deploymentTargets: .iOS("16.0"),
            sources: ["WeightMonitorTests/**/*.swift"],
            dependencies: [
                .target(name: "WeightMonitor")
            ]
        ),
    ]
)
