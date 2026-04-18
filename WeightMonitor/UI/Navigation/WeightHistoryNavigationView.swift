//
//  WeightHistoryNavigationView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import SwiftUI
import WeightMonitorFeatureWeightCreation
import WeightMonitorFeatureWeightHistory
import WeightMonitorUIComponents
import WeigthMonitorDomain

@MainActor
struct WeightHistoryNavigationView: View {
    private let weightHistoryFactory: WeightHistoryFactory
    private let weightCreationFactory: WeightCreationFactory

    @Bindable private var coordinator: WeightHistoryCoordinator

    init(
        coordinator: WeightHistoryCoordinator,
        weightHistoryFactory: WeightHistoryFactory,
        weightCreationFactory: WeightCreationFactory
    ) {
        self.coordinator = coordinator
        self.weightHistoryFactory = weightHistoryFactory
        self.weightCreationFactory = weightCreationFactory
    }

    var body: some View {
        WeightHistoryView(viewModel: weightHistoryFactory.makeViewModel(router: coordinator))
            .sheet(item: $coordinator.route) { route in
                switch route {
                case .create:
                    WeightCreationView(
                        viewModel: weightCreationFactory.makeViewModel(
                            input: .create,
                            onCompletion: coordinator.dismiss
                        )
                    )

                case .update(let weight):
                    WeightCreationView(
                        viewModel: weightCreationFactory.makeViewModel(
                            input: .update(weight),
                            onCompletion: coordinator.dismiss
                        )
                    )
                }
            }
    }
}
