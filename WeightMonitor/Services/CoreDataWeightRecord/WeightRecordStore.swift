//
//  WeightRecordStore.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation
import CoreData

final class WeightRecordStore {
    private let context: NSManagedObjectContext
    private let predicate: PredecateBuilder<WeightRecordCoreData>
    
    init(
        context: NSManagedObjectContext,
        predicate: PredecateBuilder<WeightRecordCoreData> = PredecateBuilder()
    ) {
        self.predicate = predicate
        self.context = context
    }
}

extension WeightRecordStore {
    func deleteRecord(_ record: WeightRecordCoreData) throws {
        context.delete(record)
        saveContext()
    }
    
    func saveRecordCoreData(_ record: WeightRecord) throws {
        let recordCoreData = WeightRecordCoreData(context: context)
        recordCoreData.idString = record.identifier
        recordCoreData.weight = record.weight
        recordCoreData.date = record.date
        saveContext()
    }
    
    func updateRecordWith(_ id: String, byFollowingRecod record: WeightRecord) {
        let fetchRequest = WeightRecordCoreData.fetchRequest()
        fetchRequest.predicate = predicate
            .addPredicate(.equalTo, keyPath: \.idString, value: id).build()
        
        guard let weightRecordCoreData = try? context.fetch(fetchRequest).first else { return }
        update(weightRecordCoreData, with: record)
        saveContext()
    }
    
    // Private
    private func update(_ record:  WeightRecordCoreData,
                      with newRecord: WeightRecord) {
        record.weight = newRecord.weight
        record.date = newRecord.date
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}
