import SwiftUI
import WeightCreation
import WeightHistory

@MainActor
struct WeightHistoryFlowContainer: View {
    @Bindable private var flow: WeightHistoryFlow

    var body: some View {
        NavigationStack {
            WeightHistoryView(
                viewModel: flow.weightHistoryViewModel,
                onCreateWeight: flow.openCreateWeight,
                onSelectWeight: flow.openUpdateWeight
            )
        }
        .sheet(item: $flow.routeModel) { routeModel in
            destination(for: routeModel)
        }
    }

    init(flow: WeightHistoryFlow) {
        self.flow = flow
    }

    @ViewBuilder
    private func destination(
        for routeModel: WeightHistoryFlowRouteModel
    ) -> some View {
        switch routeModel {
        case .create(_, let model), .update(_, _, let model):
            WeightCreationView(viewModel: model, onCompletion: flow.dismiss)
        }
    }
}
