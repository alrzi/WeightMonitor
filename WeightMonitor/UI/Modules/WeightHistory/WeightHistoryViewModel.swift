import Foundation
import CoreData
import Combine
import WeigthMonitorDomain

@MainActor
protocol WeightHistoryViewModelProtocol: ObservableObject, WeightHistoryNavigationState {
    var weightUnit: WeightUnit { get set }
    var isNewWeightAdded: Bool { get }
    var weights: [Weight] { get }

    func onAppear()
    func onTap(at index: Int)
    func onCreateNewWeight()
    func onDeleteTap(at index: Int)
}

final class WeightHistoryViewModel: WeightHistoryViewModelProtocol {
    private let weightManager: any WeightManaging
    private let weightUnitManager: any WeightUnitManaging

    private var weightUnitObservationTask: Task<(), Error>?
    private var isPaginating = false

    @Published private(set) var weights: [Weight] = []
    @Published private(set) var isNewWeightAdded = false

    @Published var weightUnit: WeightUnit = .metric
    @Published var route: WeightHistoryRoute?

    init(
        weightManager: any WeightManaging,
        weightUnitManager: any WeightUnitManaging
    ) {
        self.weightManager = weightManager
        self.weightUnitManager = weightUnitManager

        weightUnitObservationTask = Task { @MainActor [weak self] in
            self?.weightUnit = await weightUnitManager.weightUnit

            for try await weights in weightManager.observe() {
                self?.weights = weights
            }
        }
    }

    func onAppear() {
        Task {
            weights = try await weightManager.readAll()
        }
    }

    func onTap(at index: Int) {
        route = .update(weight: weights[index], onCompletion: { [weak self] in self?.route = nil })
    }

    func onCreateNewWeight() {
        route = .create(onCompletion: { [weak self] in self?.route = nil })
    }

    func onDeleteTap(at index: Int) {
        Task {
            try await weightManager.delete(weight: weights[index])
        }
    }

    deinit {
        weightUnitObservationTask?.cancel()
    }
}
