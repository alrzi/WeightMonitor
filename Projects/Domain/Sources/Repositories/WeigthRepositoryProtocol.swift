//
//  WeightRepositoryProtocol.swift
//  Domain
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation

public protocol WeightRepositoryProtocol: Sendable {
    @MainActor
    func observe() -> AsyncThrowingStream<[Weight], any Error>

    func create(weight: Weight) async throws
    func readAll() async throws -> [Weight]
    func paginate(after cursor: WeightCursor?, limit: Int) async throws -> [Weight]
    func update(weight: Weight) async throws
    func delete(weight: Weight) async throws
    func deleteAll() async throws
}
