import Domain
import Observation
import WeightHistory

@MainActor
@Observable
final class WeightHistoryFlow {
    // MARK: - Private properties

    private let modelFactory: WeightHistoryFlowModelFactory

    // MARK: - Public properties

    let weightHistoryViewModel: WeightHistoryViewModel

    var routeModel: WeightHistoryFlowRouteModel?

    // MARK: - Lifecycle

    init(modelFactory: WeightHistoryFlowModelFactory) {
        self.modelFactory = modelFactory
        self.weightHistoryViewModel = modelFactory.makeWeightHistoryViewModel()
    }

    // MARK: - Public methods

    func openCreateWeight() {
        present(.create)
    }

    func openUpdateWeight(_ weight: Weight) {
        present(.update(weight))
    }

    func dismiss() {
        routeModel = nil
    }

    // MARK: - Private methods

    private func present(_ route: WeightHistoryFlowRoute) {
        routeModel = modelFactory.makeRouteModel(for: route)
    }
}
