//
//  WeightManaging.swift
//  WeigthMonitorDomain
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

public protocol WeightManaging: Sendable {
    @MainActor
    func observe() -> AsyncMapSequence<AsyncThrowingStream<[Weight], any Error>, [Weight]>

    func create(weight: Weight) async throws
    func readAll() async throws -> [Weight]
    func paginate(after cursor: WeightCursor?, limit: Int) async throws -> [Weight]
    func update(weight: Weight) async throws
    func delete(weight: Weight) async throws
    func deleteAll() async throws
}
