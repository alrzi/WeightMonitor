//
//  CreateWeightViewControllerViewModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 05.05.2023.
//

import Foundation
import CoreData

final class AddWeightViewModel {
    @ObservableLocal var weightUnit: String = ""
    
    // Need to save data to core data
    private var weightRecordStore: WeightRecordStore?
    private var context: NSManagedObjectContext? {
        try? Context.getContext()
    }
    
    // MARK: - Init
    private var weightUnitService: WeightUnitServiceProtocol
    private let stringFormatter: StringFormatter
    private var userInput: UserInput
    private var recordIdForUpdate: String?
        
    init(
        weightUnitService: WeightUnitServiceProtocol = WeightSystem.shared,
        stringFormatter: StringFormatter = StringFormatter(),
        userInput: UserInput = UserInput(),
        recordId: String? = nil
    ) {
        self.weightUnitService = weightUnitService
        self.stringFormatter = stringFormatter
        self.userInput = userInput
        self.recordIdForUpdate = recordId
                
        guard let context = context else { return }
        self.weightRecordStore = WeightRecordStore(context: context)
    }
}
    
extension AddWeightViewModel {
    var isAllFieldsEntered: Bool {
        userInput.isPossibleToAddWeight
    }
        
    func setWeight(_ weight: String?) {
        guard let weight else { return }
        userInput.weight = stringFormatter.formatStringToDouble(weight)
    }
    
    func setDate(_ date: Date) {
        userInput.date = date
    }
    
    func addRecord() {
        guard let record = userInput.createRecord(unitMass: weightUnitService.currentUnit) else { return }
                    
        if
            let recordIdForUpdate,
            let followingRecod = userInput.createRecord(unitMass: weightUnitService.currentUnit)
        {
            weightRecordStore?.updateRecordWith(recordIdForUpdate, byFollowingRecod: followingRecod)
        }
        else {
            try? weightRecordStore?.saveRecordCoreData(record)
        }
    }
    
    func formatString(_ text: String) -> String {
        stringFormatter.format(text: text, for: weightUnitService.currentUnit)
    }
    
    func updateView() {
        weightUnit = weightUnitService.currentUnit.symbol
    }
}
