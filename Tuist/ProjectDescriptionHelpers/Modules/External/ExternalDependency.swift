import ProjectDescription

public enum ExternalDependency: String, CaseIterable {
    case GRDB
    case KeyValueStorage
    case Swinject
    case AsyncExtensions
    case AsyncAlgorithms
}

// MARK: - TargetDependency Helpers

extension TargetDependency {
    public static func external(_ dependency: ExternalDependency) -> Self {
        .external(name: dependency.rawValue)
    }
}
