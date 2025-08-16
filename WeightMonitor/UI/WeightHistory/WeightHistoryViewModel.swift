import Foundation

// MARK: - DataProviderDelegate
extension WeightHistoryViewModel: DataProviderDelegate {
    func dataChanged() {
        updateWeightRecords()
        ifNewRecordAddedShowNotification()
    }
    
    func didUpdate(_ update: DataProviderUpdate) {
        self.batchUpdate = update
    }
    
    func ifNewRecordAddedShowNotification() {
        if let newRecordAdded = batchUpdate?.insertedIndexes, !newRecordAdded.isEmpty {
            isNewRecordAdded = true
        }
        batchUpdate = nil
    }
}

// Dont Know yet how to add property wrappers to protocol
// MARK: - WeightHistoryViewModelProtocol
protocol WeightHistoryViewModelProtocol {
    
    var isNewRecordAdded: Bool { get set }
    var weightRecords: [WeightHistoryCellViewModel] { get set }
    var initialRecord: WeightHistoryCellViewModel? { get set }
    
    func updateWeightRecords()
    func remove(at indexPath: IndexPath)
    func setWeightUnit()
    func setWeightUnit(_ unit: UnitMass)
}

final class WeightHistoryViewModel {
    // Public
    @ObservableLocal var isNewRecordAdded: Bool = false
    @ObservableLocal var weightRecords: [WeightHistoryCellViewModel] = []
    @ObservableLocal var initialRecord: WeightHistoryCellViewModel?
    var batchUpdate: DataProviderUpdate?
    
    // Private properties
    private var weightUnitService: WeightUnitServiceProtocol = WeightSystem.shared {
        didSet {
            updateWeightRecords()
        }
    }
    
    private let weightDifferentCalculator: WeightDifferentCalculatorProtocol
    
    init(
        weightUnitService: WeightUnitServiceProtocol,
        weightDifferentCalculator: WeightDifferentCalculatorProtocol
    ) {
        self.weightUnitService = weightUnitService
        self.weightDifferentCalculator = weightDifferentCalculator
    }
    
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            return try DataProvider(delegate: self)
        } catch {
            print("Данные недоступны")
            return nil
        }
    }()
}

// MARK: - Public
extension WeightHistoryViewModel: WeightHistoryViewModelProtocol {
    func updateWeightRecords() {
        let requiredUnitWeightRecords = getRequiredUnitWeightRecords()
        let updatedWeightRecords = addWeightDifference(to: requiredUnitWeightRecords)
        self.weightRecords = mapToViewModels(updatedWeightRecords)
    }

    func remove(at indexPath: IndexPath) {
        dataProvider?.deleteRecord(indexPath)
    }
    
    func setWeightUnit() {        
        weightUnitService.currentUnit = weightUnitService.getCurrentUnit()
    }
    
    func setWeightUnit(_ unit: UnitMass) {
        weightUnitService.currentUnit = unit
    }
    
    func updateViewWnenZeroRecords() {
        let weight = Weight(
            createdAt: .now,
            mass: .init(value: 0.0, unit: .kilograms),
            massDifference: .init(value: 0.0, unit: .kilograms)
        )
        
        initialRecord = WeightHistoryCellViewModel(weight: weight)
    }
    
    func getRecordIdForIndexPath(_ indexPath: IndexPath) -> String? {        
        return dataProvider?.getRecordAt(indexPath: indexPath).idString
    }
    
    // Private
    private func getRequiredUnitWeightRecords() -> [Weight] {
        guard let weightRecords = dataProvider?.getAllWeightRecords() else {
            return []
        }
        
        return weightRecords.map { $0.withMassUnitUpdated(to: weightUnitService.currentUnit) }
    }

    private func addWeightDifference(to weightRecords: [Weight]) -> [Weight] {
        return weightDifferentCalculator.addWeightDifference(to: weightRecords)
    }

    private func mapToViewModels(_ weightRecords: [Weight]) -> [WeightHistoryCellViewModel] {
        return weightRecords.map {
            WeightHistoryCellViewModel(weight: $0)
        }
    }
}

