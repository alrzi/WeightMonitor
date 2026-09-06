import Domain
import Foundation

@MainActor
final class WatchWeightViewModel: ObservableObject {
    @Published private(set) var weights: [Weight] = []
    @Published var mass = ""
    @Published private(set) var errorMessage: String?

    private let weightManager: any WeightManaging
    private var weightsObservationTask: Task<Void, Never>?

    init(weightManager: some WeightManaging) {
        self.weightManager = weightManager

        weightsObservationTask = Task { @MainActor [weak self, weightManager] in
            do {
                for try await weights in weightManager.observe() {
                    self?.weights = weights
                }
            }
            catch {
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func load() async {
        do {
            weights = try await weightManager.readAll()
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }

    func create() async {
        guard let mass = Double(mass), mass > 0 else {
            errorMessage = "Enter a valid weight"
            return
        }

        do {
            try await weightManager.create(
                weight: Weight(
                    createdAt: .now,
                    mass: mass
                )
            )
            self.mass = ""
            await load()
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}
