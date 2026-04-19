// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WeightMonitor",
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
        .package(url: "https://github.com/alrzi/KeyValueStorage.git", branch: "main"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/alrzi/AsyncExtensions.git", branch: "main"),
    ]
)
