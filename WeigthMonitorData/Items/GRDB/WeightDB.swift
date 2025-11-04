//
//  WeightDB.swift
//  WeigthMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import GRDB
import WeigthMonitorDomain

struct WeightDB {
    var id: Int64?
    let createdAt: Date
    let mass: Double
    let massDifference: Double?
}

extension WeightDB: Codable, PersistableRecord, FetchableRecord {
    enum Columns {
        static let createdAt = Column(CodingKeys.createdAt)
        static let mass = Column(CodingKeys.mass)
        static let massDifference = Column(CodingKeys.massDifference)
    }

    static let databaseTableName = "weights"

    /// Updates a player id after it has been inserted in the database.
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

extension WeightDB {
    static func from(plain: Weight) -> Self {
        .init(
            id: plain.id,
            createdAt: plain.createdAt,
            mass: plain.mass,
            massDifference: plain.massDifference
        )
    }

    func toPlain() -> Weight {
        .init(
            id: id,
            createdAt: createdAt,
            mass: mass,
            massDifference: massDifference
        )
    }
}
