import ProjectDescription

enum WatchAppModuleName: String, CaseIterable {
    case WatchApp
}

extension WatchAppModuleName {
    var targets: [Target] {
        [Target.target(
            name: rawValue,
            destinations: [.appleWatch],
            product: .app,
            bundleId: "com.alrzi.App.WatchApp",
            deploymentTargets: .watchOS("10.0"),
            infoPlist: .extendingDefault(with: [
                "WKApplication": .boolean(true),
                "WKCompanionAppBundleIdentifier": .string("com.alrzi.App"),
            ]),
            sources: [
                .glob(.relativeToRoot("Projects/WatchApp/Sources/**/*.swift")),
            ],
            resources: [],
            dependencies: [
                TargetDependency.module(.Data),
                TargetDependency.module(.Domain),
                TargetDependency.module(.Sync),
                TargetDependency.syncImplementation,
                TargetDependency.external(.Swinject),
            ]
        )]
    }
}
