//
//  WeightHistoryAssembly.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import SwiftUI
import WeigthMonitorDomain

struct WeightHistoryAssembly {
    let weightManager: any WeightManaging
    let weightUnitManager: any WeightUnitManaging

    let weightCreationAssembly: WeightCreationAssembly

    @MainActor
    func assemble() -> some View {
        let viewModel = WeightHistoryViewModel(
            weightManager: weightManager,
            weightUnitManager: weightUnitManager
        )

        let view = WeigthHistoryNavigator(
            weightCreationAssembly: weightCreationAssembly,
            navigationState: viewModel,
            content: {
                WeightHistoryView(viewModel: viewModel)
            }
        )

        return view
    }
}
