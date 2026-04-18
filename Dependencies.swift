//
//  Dependencies.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            .remote(url: "https://github.com/groue/GRDB.swift.git", requirement: .upToNextMajor(from: "6.29.0")),
            .remote(url: "https://github.com/Swinject/Swinject.git", requirement: .upToNextMajor(from: "2.8.0")),
        ],
        productTypes: [
            "GRDB": .framework,
            "Swinject": .framework,
        ]
    )
)
