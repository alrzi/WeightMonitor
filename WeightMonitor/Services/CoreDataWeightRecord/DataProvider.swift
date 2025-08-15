//
//  DataProvider.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import Foundation
import CoreData

struct DataProviderUpdate {
    struct Move: Hashable {
        let oldIndexPath: IndexPath
        let newIndexPath: IndexPath
    }
    var insertedSection: IndexSet
    var deletedSection: IndexSet
    var insertedIndexes: IndexPath
    var deletedIndexes: IndexPath
    var updatedIndexes: IndexPath
    let movedIndexes: Set<Move>
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: DataProviderUpdate)
    func dataChanged()
}

protocol DataProviderProtocol {
    func deleteRecord(_ indexPath: IndexPath)
    func addRecord(_ record: WeightRecord)
    func getAllWeightRecords() -> [WeightRecord]
    func getRecordAt(indexPath: IndexPath) -> WeightRecordCoreData
}

final class DataProvider: NSObject {
    // Idexes for delegate
    private var insertedSection: IndexSet?
    private var deletedSection: IndexSet?
    private var insertedIndexes: IndexPath?
    private var deletedIndexes: IndexPath?
    private var updatedIndexes: IndexPath?
    private var movedIndexes: Set<DataProviderUpdate.Move>?
    
    private let context: NSManagedObjectContext
    private let weightRecordStore: WeightRecordStore   
    private let weightUnitService = WeightSystem.shared   
    weak var delegate: DataProviderDelegate?
    
    
    // Fetch controller
    private lazy var fetchedResultsController: NSFetchedResultsController<WeightRecordCoreData> = {
        let fetchRequest = WeightRecordCoreData.fetchRequest()
        fetchRequest.fetchBatchSize = 50
        fetchRequest.fetchLimit = 50
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(WeightRecordCoreData.date), ascending: false)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()            
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - Init
    init(delegate: DataProviderDelegate?) throws {
        let context = try Context.getContext()
        
        self.delegate = delegate
        self.context = context
        self.weightRecordStore = WeightRecordStore(context: context)
    }
}

extension DataProvider: DataProviderProtocol {
    func getAllWeightRecords() -> [WeightRecord] {
        guard let weightRecordCoreData = fetchedResultsController.fetchedObjects
        else { return [] }
        return weightRecordCoreData.map { $0.createWeightRecord() }
    }
    
    func addRecord(_ record: WeightRecord) {
        try? weightRecordStore.saveRecordCoreData(record)       
    }
    
    func deleteRecord(_ indexPath: IndexPath) {
        let record = fetchedResultsController.object(at: indexPath)
        try? weightRecordStore.deleteRecord(record)
    }
    
    func getRecordAt(indexPath: IndexPath) -> WeightRecordCoreData {
        return fetchedResultsController.object(at: indexPath)
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSection = IndexSet()
        deletedSection = IndexSet()
        insertedIndexes = IndexPath()
        deletedIndexes = IndexPath()
        updatedIndexes = IndexPath()
        movedIndexes = Set<DataProviderUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        provideUpdateWithData()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            insertedIndexes = newIndexPath
        case .delete:
            guard let indexPath = indexPath else { return }
            deletedIndexes = indexPath           
        case .update:
            guard let indexPath = indexPath else { return }
            updatedIndexes = indexPath
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            movedIndexes?.insert(.init(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath))
        @unknown default:
            break
        }
    }
    
    // Private
    func provideUpdateWithData() {
        guard let insertedSectionIndexSet = insertedSection,
            let deletedSectionIndexSet = deletedSection,
            let insertedItem = insertedIndexes,
            let deletedItem = deletedIndexes,
            let updatedItem = updatedIndexes,
            let movedItem = movedIndexes else {
            return
        }
        
        let update = DataProviderUpdate(
            insertedSection: insertedSectionIndexSet,
            deletedSection: deletedSectionIndexSet,
            insertedIndexes: insertedItem,
            deletedIndexes: deletedItem,
            updatedIndexes: updatedItem,
            movedIndexes: movedItem
        )

        // Update delegate
        delegate?.didUpdate(update)
        delegate?.dataChanged()
        
        
        insertedSection = nil
        deletedSection = nil
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
}
