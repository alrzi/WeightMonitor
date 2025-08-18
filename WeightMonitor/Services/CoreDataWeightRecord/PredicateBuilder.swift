//
//  PredicateBuilder.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 07.05.2023.
//

import Foundation

final class PredecateBuilder<T> {
    private var predicates: [NSPredicate] = []
    
    func addPredicate(_ predicateType: PredicateType, keyPath: KeyPath<T, String>, value: String) -> PredecateBuilder {
        let predicate = predicateType.predicate(keyPath: keyPath, value: value)
        predicates.append(predicate)
        return self
    }
    
    func build(type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
        let predicates = predicates
        self.predicates.removeAll()
        return NSCompoundPredicate(type: type, subpredicates: predicates)
    }
}

enum PredicateType {
    case equalTo
    case notEqualTo
    case greaterThan
    case lessThan
    case contains
    case beginsWith
    case endsWith
    
    func predicate<T>(keyPath: KeyPath<T, String>, value: String) -> NSPredicate {
        let format: String
        switch self {
        case .equalTo:
            format = "%K == %@"
        case .notEqualTo:
            format = "NOT (%K == %@)"
        case .greaterThan:
            format = "%K > %@"
        case .lessThan:
            format = "%K < %@"
        case .contains:
            format = "%K CONTAINS[cd] %@"
        case .beginsWith:
            format = "%K BEGINSWITH[cd] %@"
        case .endsWith:
            format = "%K ENDSWITH[cd] %@"
        }
        return NSPredicate(format: format, keyPath._kvcKeyPathString ?? "", value)
    }
}
