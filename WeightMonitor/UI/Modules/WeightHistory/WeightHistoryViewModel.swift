import Foundation
import CoreData
import Combine
import WeigthMonitorDomain

protocol WeightHistoryViewModelProtocol: ObservableObject, WeightHistoryNavigationState {
    var weightUnit: WeightUnit { get set }
    var weightsState: WeightsState? { get }

    func onAppear()
    func onWeightAppear(at index: Int)
    func onTap(at index: Int)
    func onCreateNewWeight()
    func onDeleteTap(at index: Int)
}

final class WeightHistoryViewModel: WeightHistoryViewModelProtocol {
    private let weightManager: any WeightManaging
    private let weightUnitManager: any WeightUnitManaging

    private var weightUnitCancellable: AnyCancellable?
    private var weightUnitObservationTask: Task<(), Error>?
    private var isPaginating = false

    @Published private(set) var weightsState: WeightsState?
    @Published private(set) var isNewWeightAdded = false

    @Published var weightUnit: WeightUnit = .metric
    @Published var route: WeightHistoryRoute?

    init(
        weightManager: any WeightManaging,
        weightUnitManager: any WeightUnitManaging
    ) {
        self.weightManager = weightManager
        self.weightUnitManager = weightUnitManager
        self.weightUnit = weightUnitManager.lastSelectedWeightUnit

        weightUnitCancellable = $weightUnit            
            .sink(receiveValue: { unit in
                Task { await weightUnitManager.set(unit: unit) }
            })

        weightUnitObservationTask = Task { @MainActor [weak self] in
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

            let newWeights = try await weightManager.paginate(after: nil, limit: WeightsState.pageSize)

            weightsState = .init(weights: newWeights)
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

            let newWeights = try await weightManager.paginate(after: cursor, limit: WeightsState.pageSize)

            weightsState?.onWeigthLoaded(newWeights: newWeights)
        }
    }

    func onTap(at index: Int) {
        guard let weight = weightsState?.weights[index] else {
            return
        }

        route = .update(weight: weight, onCompletion: { [weak self] in self?.route = nil })
    }

    func onCreateNewWeight() {
        route = .create(onCompletion: { [weak self] in self?.route = nil })
    }

    func onDeleteTap(at index: Int) {
        guard let weight = weightsState?.weights[index] else {
            return
        }

        Task {
            try await weightManager.delete(weight: weight)
        }
    }

    deinit {
        weightUnitObservationTask?.cancel()
    }
}
