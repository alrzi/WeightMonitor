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
    private let weightUnitConverter: WeightUnitConverter
    private let weightDifferentCalculator: WeightDifferentCalculatorProtocol
    
    init(weightUnitService: WeightUnitServiceProtocol,
         weightUnitConverter: WeightUnitConverter,
         weightDifferentCalculator: WeightDifferentCalculatorProtocol) {
        self.weightUnitService = weightUnitService
        self.weightUnitConverter = weightUnitConverter
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
        let weightRecord = WeightRecord(date: Date(), weight: 0, weightDifference: 0)
        initialRecord = WeightHistoryCellViewModel(weightRecord: weightRecord)
    }
    
    func getRecordIdForIndexPath(_ indexPath: IndexPath) -> String? {        
        return dataProvider?.getRecordAt(indexPath: indexPath).idString
    }
    
    // Private
    private func getRequiredUnitWeightRecords() -> [WeightRecord] {
        guard let weightRecords = dataProvider?.getAllWeightRecords() else {
            return []
        }
        
        return weightRecords.map {
            self.weightUnitConverter.convertUnitsOfWeight(to: weightUnitService.currentUnit, $0)
        }
    }

    private func addWeightDifference(to weightRecords: [WeightRecord]) -> [WeightRecord] {
        return weightDifferentCalculator.addWeightDifference(to: weightRecords)
    }

    private func mapToViewModels(_ weightRecords: [WeightRecord]) -> [WeightHistoryCellViewModel] {
        return weightRecords.map {
            WeightHistoryCellViewModel(weightRecord: $0)
        }
    }
}

