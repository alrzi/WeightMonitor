import Combine
import WeightMonitorUIComponents
import CoreData
import Foundation
import WeigthMonitorDomain

@MainActor
protocol WeightHistoryViewModelProtocol: ObservableObject {
    var weightUnit: WeightUnit { get set }
    var alertModel: AlertModel? { get set }
    var weightsState: WeightsState? { get }

    func onAppear()
    func onWeightAppear(at index: Int)
    func onTap(at index: Int)
    func onCreateNewWeight()
    func onDeleteTap(at index: Int)
}

public final class WeightHistoryViewModel: WeightHistoryViewModelProtocol {
    private let weightManager: any WeightManaging
    private let weightUnitManager: any WeightUnitManaging
    private let router: WeightHistoryRouter

    private var weightUnitCancellable: AnyCancellable?
    private var weightsObservationTask: Task<(), Error>?
    private var isPaginating = false

    @Published private(set) var weightsState: WeightsState?
    @Published private(set) var isNewWeightAdded = false

    @Published var alertModel: AlertModel?
    @Published var weightUnit: WeightUnit = .metric

    init(
        weightManager: any WeightManaging,
        weightUnitManager: any WeightUnitManaging,
        router: WeightHistoryRouter
    ) {
        self.weightManager = weightManager
        self.weightUnitManager = weightUnitManager
        self.router = router
        self.weightUnit = weightUnitManager.lastSelectedWeightUnit

        weightUnitCancellable =
            $weightUnit
            .sink(receiveValue: { unit in
                Task { await weightUnitManager.set(unit: unit) }
            })

        weightsObservationTask = Task { @MainActor [weak self] in
            for try await weights in weightManager.observe().dropFirst() {
                self?.weightsState?.onObservedWeithsChenged(newWeights: weights)
            }
        }
    }

    func onAppear() {
        Task {
            guard !isPaginating else { return }
            isPaginating = true
            defer { isPaginating = false }

            do {
                let newWeights = try await weightManager.paginate(after: nil, limit: WeightsState.pageSize)

                weightsState = .init(weights: newWeights)
            }
            catch {
                alertModel = .loadFailed { [weak self] in self?.onAppear() }
            }
        }
    }

    func onWeightAppear(at index: Int) {
        guard weightsState?.shouldLoadMore(at: index) == true else {
            return
        }

        Task {
            guard !isPaginating, let cursor = weightsState?.nextCursor else { return }
            isPaginating = true
            defer { isPaginating = false }

            do {
                let newWeights = try await weightManager.paginate(after: cursor, limit: WeightsState.pageSize)

                weightsState?.onWeigthLoaded(newWeights: newWeights)
            }
            catch {
                alertModel = .paginationFailed
            }
        }
    }

    func onTap(at index: Int) {
        guard let weight = weightsState?.weights.elementOrNil(at: index) else {
            return
        }

        router.openUpdateWeight(weight)
    }

    func onCreateNewWeight() {
        router.openCreateWeight()
    }

    func onDeleteTap(at index: Int) {
        guard let weight = weightsState?.weights.elementOrNil(at: index) else {
            return
        }

        Task {
            do {
                try await weightManager.delete(weight: weight)
            }
            catch {
                alertModel = .deletionFailed { [weak self] in self?.onDeleteTap(at: index) }
            }
        }
    }

    deinit {
        weightsObservationTask?.cancel()
    }
}

extension AlertModel {
    fileprivate static func loadFailed(retryHandler: @escaping () -> Void) -> Self {
        Self(
            title: "Load failed",
            message: "We couldn’t retrieve the data. Please try again.",
            action: .cancel(Action.AlertButton(title: "Retry", handler: retryHandler))
        )
    }

    fileprivate static var paginationFailed: Self {
        Self(
            title: "Pagination error",
            message: "Unable to load more items. Please try again later.",
            action: .cancel(Action.AlertButton(title: "Cancel"))
        )
    }

    fileprivate static func deletionFailed(retryHandler: @escaping () -> Void) -> Self {
        Self(
            title: "Deletion failed",
            message: "The item could not be removed. Please try again.",
            action: .destructive(Action.AlertButton(title: "Delete", handler: retryHandler))
        )
    }
}
