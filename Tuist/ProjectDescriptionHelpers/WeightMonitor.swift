//  WeightMonitor.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

public enum WeightMonitor: String, CaseIterable {
    case Domain
    case Sync
    case Data
    case UIComponents
    case WeightCreation
    case WeightHistory
    case App
    case WatchApp
}

extension WeightMonitor {
    public var project: Project {
        switch self {
        case .Domain:
            Project(
                name: rawValue,
                targets: DomainModuleName.allCases.flatMap(\.targets)
            )
        case .Sync:
            Project(
                name: rawValue,
                targets: SyncModuleName.allCases.flatMap(\.targets)
            )
        case .Data:
            Project(
                name: rawValue,
                targets: DataModuleName.allCases.flatMap(\.targets)
            )
        case .UIComponents:
            Project(
                name: rawValue,
                targets: UIComponentsModuleName.allCases.flatMap(\.targets)
            )
        case .WeightCreation:
            Project(
                name: rawValue,
                targets: WeightCreationModuleName.allCases.flatMap(\.targets),
            )
        case .WeightHistory:
            Project(
                name: rawValue,
                targets: WeightHistoryModuleName.allCases.flatMap(\.targets)
            )
        case .App:
            Project(
                name: rawValue,
                targets: AppModuleName.allCases.flatMap(\.targets)
                    + WatchAppModuleName.allCases.flatMap(\.targets)
            )
        case .WatchApp:
            Project(
                name: rawValue,
                targets: WatchAppModuleName.allCases.flatMap(\.targets)
            )
        }
    }
}

extension WeightMonitor {
    public var projectPath: Path {
        switch self {
        case .Domain, .Sync, .Data, .App, .WatchApp: .relativeToRoot("Projects/\(rawValue)")
        case .UIComponents, .WeightCreation, .WeightHistory: .relativeToRoot("Projects/Features/\(rawValue)")
        }
    }
}
