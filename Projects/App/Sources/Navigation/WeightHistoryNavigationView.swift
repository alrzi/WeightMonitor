//
//  WeightHistoryNavigationView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import Domain
import SwiftUI
import UIComponents
import WeightCreation
import WeightHistory

@MainActor
struct WeightHistoryNavigationView: View {
    private let weightHistoryFactory: WeightHistoryFactory
    private let weightCreationFactory: WeightCreationFactory

    @Bindable private var coordinator: WeightHistoryCoordinator
    @StateObject private var viewModel: WeightHistoryViewModel

    init(
        coordinator: WeightHistoryCoordinator,
        weightHistoryFactory: WeightHistoryFactory,
        weightCreationFactory: WeightCreationFactory
    ) {
        self.coordinator = coordinator
        self.weightHistoryFactory = weightHistoryFactory
        self.weightCreationFactory = weightCreationFactory
        self._viewModel = StateObject(wrappedValue: weightHistoryFactory.makeViewModel(router: coordinator))
    }

    var body: some View {
        WeightHistoryView(viewModel: viewModel)
            .sheet(item: $coordinator.route) { route in
                switch route {
                case .create:
                    WeightCreationView(
                        viewModel: weightCreationFactory.makeViewModel(
                            input: .create,
                            onCompletion: { coordinator.dismiss() }
                        )
                    )

                case .update(let weight):
                    WeightCreationView(
                        viewModel: weightCreationFactory.makeViewModel(
                            input: .update(weight),
                            onCompletion: { coordinator.dismiss() }
                        )
                    )
                }
            }
    }
}
