//
//  Context.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import CoreData
import UIKit

enum Context {
    enum DataProviderError: Error {
        case contextUnavailable
    }
    
    static func getContext() throws -> NSManagedObjectContext {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?
            .persistentContainer.viewContext else {
            throw DataProviderError.contextUnavailable
        }
        return context
    }
}
