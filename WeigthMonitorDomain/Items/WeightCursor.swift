//
//  WeightCursor.swift
//  WeigthMonitorDomain
//
//  Created by Александр Зиновьев on 29.10.2025.
//

import Foundation

public struct WeightCursor: Sendable, Equatable {
    public let createdAt: Date
    public let id: Int64

    public init(createdAt: Date, id: Int64) {
        self.createdAt = createdAt
        self.id = id
    }
}

