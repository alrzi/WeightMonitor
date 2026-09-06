import ProjectDescription

enum SyncModuleName: String, CaseIterable {
    case Sync
    case SyncImplementation
}

extension SyncModuleName {
    var targets: [Target] {
        switch self {
        case .Sync:
            Target.module(
                name: rawValue,
                product: .framework,
                destinations: [.iPhone, .appleWatch],
                deploymentTargets: .multiplatform(
                    iOS: "17.0",
                    watchOS: "10.0"
                ),
                testDeploymentTargets: .iOS("17.0"),
                hasTests: false,
                sources: ["Sources/Public/**/*.swift"],
                resources: []
            )

        case .SyncImplementation:
            Target.module(
                name: rawValue,
                product: .framework,
                destinations: [.iPhone, .appleWatch],
                deploymentTargets: .multiplatform(
                    iOS: "17.0",
                    watchOS: "10.0"
                ),
                testDeploymentTargets: .iOS("17.0"),
                sources: ["Sources/Private/**/*.swift"],
                resources: [],
                dependencies: [.target(name: SyncModuleName.Sync.rawValue)],
                testDependencies: [.target(name: SyncModuleName.Sync.rawValue)]
            )
        }
    }
}
