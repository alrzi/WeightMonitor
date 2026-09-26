//
//  WeightDB.swift
//  WeightMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import GRDB
import Domain
import Sync

struct WeightDB {
    let id: String
    let createdAt: Date
    let mass: Double
    let massDifference: Double?
}

extension WeightDB: GRDBSyncRecord {
    typealias Value = Weight

    static let syncDataType = SyncDataType(rawValue: "weight")
}

extension WeightDB: Codable, PersistableRecord, FetchableRecord {
    static let databaseTableName = "weights"

    enum Columns {
        static let createdAt = Column(CodingKeys.createdAt)
        static let mass = Column(CodingKeys.mass)
        static let massDifference = Column(CodingKeys.massDifference)
    }
}

extension WeightDB {
    static func from(plain: Weight) -> Self {
        .init(
            id: plain.id.uuidString,
            createdAt: plain.createdAt,
            mass: plain.mass,
            massDifference: plain.massDifference
        )
    }

    func toPlain() throws -> Weight {
        guard let id = UUID(uuidString: id) else {
            throw WeightDBMappingError.invalidIdentifier(id)
        }

        return .init(
            id: id,
            createdAt: createdAt,
            mass: mass,
            massDifference: massDifference
        )
    }
}
