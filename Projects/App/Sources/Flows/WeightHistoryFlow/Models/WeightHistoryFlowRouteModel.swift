import Foundation
import WeightCreation

enum WeightHistoryFlowRouteModel: Identifiable {
    case create(
        id: UUID,
        model: WeightCreationViewModel
    )
    case update(
        route: WeightHistoryFlowRoute,
        id: UUID,
        model: WeightCreationViewModel
    )

    var id: UUID {
        switch self {
        case .create(let id, _):
            id

        case .update(_, let id, _):
            id
        }
    }

    var route: WeightHistoryFlowRoute {
        switch self {
        case .create:
            .create

        case .update(let route, _, _):
            route
        }
    }
}
