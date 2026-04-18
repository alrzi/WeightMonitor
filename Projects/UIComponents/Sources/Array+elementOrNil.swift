//
//  Array+elementOrNil.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

public extension Array {
    func elementOrNil(at index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }

        return self[index]
    }
}
