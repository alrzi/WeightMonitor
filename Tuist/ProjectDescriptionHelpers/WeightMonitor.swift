//  WeightMonitor.swift
//  ProjectDescriptionHelpers
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription

public enum WeightMonitor: String, CaseIterable {
    case Domain
    case Data
    case UIComponents
    case WeightCreation
    case WeightHistory
    case App
}

extension WeightMonitor {
    public var project: Project {
        switch self {
        case .Domain:
            Project(
                name: rawValue,
                targets: DomainModuleName.allCases.flatMap(\.targets)
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
            )
        }
    }
}

extension WeightMonitor {
    public var projectPath: Path {
        switch self {
        case .Domain, .Data, .App: .relativeToRoot("Projects/\(rawValue)")
        case .UIComponents, .WeightCreation, .WeightHistory: .relativeToRoot("Projects/Features/\(rawValue)")
        }
    }
}
