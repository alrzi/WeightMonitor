//
//  WeightMonitorTests.swift
//  WeightMonitorTests
//
//  Created by Александр Зиновьев on 25.05.2023.
//

import XCTest
@testable import WeightMonitor

final class WeightMonitorTests: XCTestCase {
    func testAddWeightDifference() {
        let sut = WeightDifferentCalculator()
        
        let records = [
            Weight(id: "1", createdAt: Date(), mass: 150.0, massDifference: nil),
            Weight(id: "2", createdAt: Date().addingTimeInterval(86400), mass: 148.5, massDifference: nil),
            Weight(id: "3", createdAt: Date().addingTimeInterval(172800), mass: 147.0, massDifference: nil)
        ]
        
        let expectedRecords = [
            Weight(id: "1", createdAt: Date(), mass: 150.0, massDifference: +1.5),
            Weight(id: "2", createdAt: Date().addingTimeInterval(86400), mass: 148.5, massDifference: +1.5),
            Weight(id: "3", createdAt: Date().addingTimeInterval(172800), mass: 147.0, massDifference: nil)
        ]
    
        let updatedRecords = sut.addWeightDifference(to: records)
        XCTAssertEqual(updatedRecords, expectedRecords)
    }
    
    func testConvertingToKilograms() {
        let sut = WeightUnitConverter()
        let record = Weight(createdAt: Date(), mass: 200, massDifference: 5.0)
        
        let convertedRecord = sut.convertUnitsOfWeight(to: UnitMass.kilograms, record)
        
        
        XCTAssertEqual(convertedRecord.weight, 200.0, accuracy: 0.001)
        if let weightDiff = convertedRecord.massDifference {
            XCTAssertEqual(weightDiff, 5.0, accuracy: 0.001)
        }
    }
    
    func testConvertingToPounds() {
        let sut = WeightUnitConverter()
        let record = Weight(createdAt: Date(), mass: 90.72, massDifference: -2.27)
        
        let convertedRecord = sut.convertUnitsOfWeight(to: UnitMass.pounds, record)
        
        // 200 lbs in kg and 5 lbs in 2.27 kg
        XCTAssertEqual(convertedRecord.weight, 200.0, accuracy: 0.01)
        if let weightDiff = convertedRecord.massDifference {
            XCTAssertEqual(weightDiff, -5.0, accuracy: 0.01)
        }
    }
}
