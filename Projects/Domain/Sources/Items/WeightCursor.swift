//
//  WeightCursor.swift
//  Domain
//
//  Created by Александр Зиновьев on 29.10.2025.
//

import Foundation

public struct WeightCursor: Sendable, Equatable {
    public let createdAt: Date
    public let id: UUID

    public init(createdAt: Date, id: UUID) {
        self.createdAt = createdAt
        self.id = id
    }
}
