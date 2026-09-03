import Domain
import Foundation
import WeightCreation
import WeightHistory

@MainActor
struct WeightHistoryFlowModelFactory {
    // MARK: - Private properties

    private let weightCreationFactory: WeightCreationFactory
    private let weightHistoryFactory: WeightHistoryFactory

    // MARK: - Lifecycle

    init(
        weightCreationFactory: WeightCreationFactory,
        weightHistoryFactory: WeightHistoryFactory
    ) {
        self.weightCreationFactory = weightCreationFactory
        self.weightHistoryFactory = weightHistoryFactory
    }

    // MARK: - Public methods

    func makeWeightHistoryViewModel() -> WeightHistoryViewModel {
        weightHistoryFactory.makeViewModel()
    }

    func makeRouteModel(
        for route: WeightHistoryFlowRoute
    ) -> WeightHistoryFlowRouteModel {
        switch route {
        case .create:
            .create(
                id: UUID(),
                model: weightCreationFactory.makeViewModel(input: .create)
            )

        case .update(let weight):
            .update(
                route: route,
                id: UUID(),
                model: weightCreationFactory.makeViewModel(input: .update(weight))
            )
        }
    }
}
