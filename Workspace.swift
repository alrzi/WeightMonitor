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
    projects: WeightMonitor.allCases.map(\.projectPath)
)
