//
import WeightMonitorUIComponents
//  WeightsState.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.11.2025.
//

import Foundation
import WeigthMonitorDomain

struct WeightsState: Equatable {
    static let pageSize = 20

    private(set) var pageCount = 1
    private(set) var nextCursor: WeightCursor?
    private(set) var weights: [Weight] = []

    init(weights: [Weight]) {
        self.weights = weights.updateWeightsDiff()
        self.nextCursor = Self.getCursorIfPossible(weights: weights)
    }

    mutating func onWeigthLoaded(newWeights: [Weight]) {
        let withLast = weights.last.flatMap { [$0] + newWeights } ?? newWeights
        let start = weights.count - 1
        let end = weights.count
        let diffedBatch = withLast.updateWeightsDiff()

        pageCount += 1
        weights.replaceSubrange(start..<end, with: diffedBatch)
        nextCursor = Self.getCursorIfPossible(weights: newWeights)
    }

    mutating func onObservedWeithsChenged(newWeights: [Weight]) {
        let count = max(0, newWeights.count - Self.pageSize * pageCount)
        let weightsToAdd = Array(newWeights.dropLast(count))

        weights = weightsToAdd.updateWeightsDiff()
        nextCursor = weightsToAdd.last?.toCursorIfPossible()
    }

    func shouldLoadMore(at index: Int) -> Bool {
        let endIndex = weights.endIndex
        let startIndex = weights.startIndex
        let offsetBy = 2

        guard index > offsetBy else {
            return false
        }

        let thresholdIndex = weights.index(endIndex, offsetBy: -offsetBy, limitedBy: startIndex)

        return index >= thresholdIndex ?? weights.startIndex
    }
}

private extension WeightsState {
    static func getCursorIfPossible(weights: [Weight]) -> WeightCursor? {
        guard weights.count == pageSize, let last = weights.last else {
            return nil
        }

        return last.toCursorIfPossible()
    }
}

private extension Array where Element == Weight {
    func updateWeightsDiff() -> [Weight] {
        self
            .enumerated()
            .map { index, record in
                guard let nextRecord = elementOrNil(at: index + 1) else {
                    return record
                }

                return record.difference(with: nextRecord)
            }
    }
}
