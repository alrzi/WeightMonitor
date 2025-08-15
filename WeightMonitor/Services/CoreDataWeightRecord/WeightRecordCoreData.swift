//
//  WeightRecordCoreData.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.05.2023.
//

import Foundation
import CoreData

@objc(WeightRecordCoreData)
class WeightRecordCoreData: NSManagedObject {
    static func fetchRequest() -> NSFetchRequest<WeightRecordCoreData> {
         let request: NSFetchRequest<WeightRecordCoreData> = NSFetchRequest(entityName: String(describing: self))
         request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
         return request
     }
    
    @NSManaged var idString: String
    @NSManaged var weight: Double
    @NSManaged var date: Date
    
    func createWeightRecord() -> WeightRecord {
        let record = WeightRecord(id: self.idString, date: self.date, weight: self.weight)
        return record
    }
}
