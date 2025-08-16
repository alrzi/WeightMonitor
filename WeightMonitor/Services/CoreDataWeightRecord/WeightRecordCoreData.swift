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
    
    func createWeightRecord(unitMass: UnitMass) -> Weight {
        let savedWeight = Measurement<UnitMass>(value: weight, unit: .kilograms)
        let mass = savedWeight.converted(to: unitMass)
        
        return Weight(createdAt: date, mass: mass)
    }
}
