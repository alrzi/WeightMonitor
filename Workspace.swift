//
//  Workspace.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "WeightMonitor",
    projects: WeightMonitor.allCases.filter { $0 != .WatchApp }.map(\.projectPath)
)
