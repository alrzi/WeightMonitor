// swift-tools-version: 6.0

import PackageDescription

#if TUIST
import ProjectDescription
#endif

let package = Package(
    name: "WeightMonitor",
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
        .package(url: "https://github.com/alrzi/KeyValueStorage.git", branch: "main"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/alrzi/AsyncExtensions.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", exact: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.0.4"),
    ]
)

#if TUIST
let packageSettings = PackageSettings(
    baseSettings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            "WATCHOS_DEPLOYMENT_TARGET": "10.0",
        ]
    )
)
#endif
