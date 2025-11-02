//
//  WeightsState.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.11.2025.
//

import Foundation
import WeigthMonitorDomain

struct WeightsState: Equatable {
    static let pageSize = 20

    private var pageCount = 1

    private(set) var nextCursor: WeightCursor?
    private(set) var weights: [Weight] = []

    init(weights: [Weight]) {
        self.weights = weights.updateWeightsDiff()
        self.nextCursor = Self.getCursorIfPossible(weights: weights)
    }

    mutating func onWeigthLoaded(newWeights: [Weight]) {
        let withLast = weights.last.flatMap { [$0] + newWeights } ?? newWeights

        pageCount += 1
        weights.removeLast()
        weights.append(contentsOf: withLast.updateWeightsDiff())
        nextCursor = Self.getCursorIfPossible(weights: newWeights)
    }

    mutating func onObservedWeithsChenged(newWeights: [Weight], cursor: WeightCursor?) {
        let weightsToAdd = Array(newWeights.dropLast(max(0, newWeights.count - Self.pageSize * pageCount)))

        weights = weightsToAdd.updateWeightsDiff()
        nextCursor = cursor
    }

    func shouldLoadMore(at index: Int) -> Bool {
        let thresholdIndex = weights.index(weights.endIndex, offsetBy: -2, limitedBy: weights.startIndex)

        return index >= thresholdIndex ?? weights.startIndex
    }
}

private extension WeightsState {
    static func getCursorIfPossible(weights: [Weight]) -> WeightCursor? {
        guard weights.count == pageSize, let last = weights.last else {
            return nil
        }

        return last.id.map { .init(createdAt: last.createdAt, id: $0) }
    }
}

private extension Array where Element == Weight {
    func updateWeightsDiff() -> [Weight] {
        self
            .enumerated()
            .map { index, record in
                let nextRecord = index < self.count - 1 ? self[index+1] : nil

                guard let nextRecord else {
                    return record
                }

                return record.difference(with: nextRecord)
            }
    }
}
