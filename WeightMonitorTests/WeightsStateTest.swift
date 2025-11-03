//
//  WeightsStateTest.swift
//  WeightMonitorTests
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation
import Testing
import WeigthMonitorDomain
@testable import WeightMonitor

@Suite
struct WeightsStatessTest {
    // MARK: – Test data helpers

    private let pageSize = WeightsState.pageSize

    private func makeFullPageWeights(startingAt start: Int64 = 1) -> [Weight] {
        let range: ClosedRange<Int64> = start...(start + Int64(pageSize) - 1)
        return range.map { Weight(id: $0, createdAt: .now, mass: 70.0) }
    }

    private func makeWeights(count: Int, mass: Double = 75.0) -> [Weight] {
        (0..<count).map { Weight(id: Int64($0), createdAt: .now, mass: mass) }
    }

    // MARK: – Initialization

    @Test func test_initialState_hasCorrectPageCount_andWeightCount() {
        // GIVEN
        let initial = [Weight(id: 1, createdAt: .now, mass: 70.5)]

        // WHEN
        let state = WeightsState(weights: initial)

        // THEN
        #expect(state.pageCount == 1)
        #expect(state.weights.count == initial.count)
    }

    @Test func test_initialState_hasNoNextCursor_whenOnlyOnePage() {
        // GIVEN
        let initial = [Weight(id: 1, createdAt: .now, mass: 70.5)]

        // WHEN
        let state = WeightsState(weights: initial)

        // THEN
        #expect(state.nextCursor == nil)
    }

    @Test func test_initialState_hasNextCursor_whenFullPageProvided() {
        // GIVEN
        let fullPage = makeFullPageWeights()

        // WHEN
        let state = WeightsState(weights: fullPage)

        // THEN
        #expect(state.nextCursor != nil)
    }

    // MARK: – Loading new pages

    @Test func test_onWeightLoaded_incrementsPageCount() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let newPage = makeFullPageWeights(startingAt: Int64(pageSize) + 1)

        // WHEN
        state.onWeigthLoaded(newWeights: newPage)

        // THEN
        #expect(state.pageCount == 2)
    }

    @Test func test_onWeightLoaded_updatesNextCursor() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let newPage = makeFullPageWeights(startingAt: Int64(pageSize) + 1)

        // WHEN
        state.onWeigthLoaded(newWeights: newPage)

        // THEN
        #expect(state.nextCursor != nil)
    }

    @Test func test_onWeightLoaded_accumulatesWeights_toExpectedCount() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let newPage = makeFullPageWeights(startingAt: Int64(pageSize) + 1)

        // WHEN
        state.onWeigthLoaded(newWeights: newPage)

        // THEN
        let expected = pageSize * 2
        #expect(state.weights.count == expected)
    }

    @Test func test_onWeightLoaded_setsMassDifference_forAllButLast() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let newPage = makeFullPageWeights(startingAt: Int64(pageSize) + 1)

        // WHEN
        state.onWeigthLoaded(newWeights: newPage)

        // THEN
        state.weights.dropLast().forEach { #expect($0.massDifference != nil) }
        #expect(state.weights.last?.massDifference == nil)
    }

    // MARK: – Pagination helper

    @Test func test_shouldLoadMore_returnsTrue_whenIndexNearEndOfPage() {
        // GIVEN
        let state = WeightsState(weights: makeFullPageWeights())

        // WHEN
        let result = state.shouldLoadMore(at: pageSize - 2)

        // THEN
        #expect(result == true)
    }

    @Test func test_shouldLoadMore_returnsFalse_whenIndexNotNearEnd() {
        // GIVEN
        let state = WeightsState(weights: makeFullPageWeights())

        // WHEN
        let result = state.shouldLoadMore(at: pageSize - 3)

        // THEN
        #expect(result == false)
    }

    @Test func test_shouldLoadMore_returnsFalse_whenElementsAFew() {
        // GIVEN
        let state = WeightsState(weights: makeWeights(count: 2))

        // WHEN
        let result = state.shouldLoadMore(at: 2)

        // THEN
        #expect(result == false)
    }

    // MARK: – Observed weight changes

    @Test func test_onObservedWeightsChanged_keepsOriginalPageCount() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let originalPageCount = state.pageCount
        let updated = makeFullPageWeights(startingAt: Int64(pageSize) + 1)
            .map { Weight(id: $0.id! + Int64(pageSize), createdAt: .now, mass: 75.0) }

        // WHEN
        state.onObservedWeithsChenged(newWeights: updated)

        // THEN
        #expect(state.pageCount == originalPageCount)
    }

    @Test func test_onObservedWeightsChanged_limitsWeightCount_toPageSize() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let updated = makeFullPageWeights(startingAt: Int64(pageSize) + 1)
            .map { Weight(id: $0.id! + Int64(pageSize), createdAt: .now, mass: 75.0) }

        // WHEN
        state.onObservedWeithsChenged(newWeights: updated)

        // THEN
        #expect(state.weights.count == pageSize)
    }

    @Test func test_onObservedWeightsChanged_preservesNextCursor() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let updated = makeFullPageWeights(startingAt: Int64(pageSize) + 1)
            .map { Weight(id: $0.id! + Int64(pageSize), createdAt: .now, mass: 75.0) }

        // WHEN
        state.onObservedWeithsChenged(newWeights: updated)

        // THEN
        #expect(state.nextCursor != nil)
    }

    @Test func test_onObservedWeightsChanged_setsMassDifference_forAllButLast() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let updated = makeFullPageWeights(startingAt: Int64(pageSize) + 1)
            .map { Weight(id: $0.id! + Int64(pageSize), createdAt: .now, mass: 75.0) }

        // WHEN
        state.onObservedWeithsChenged(newWeights: updated)

        // THEN
        state.weights.dropLast().forEach { #expect($0.massDifference != nil) }
        #expect(state.weights.last?.massDifference == nil)
    }

    @Test func test_onObservedWeightsChanged_withManyItems_keepsPageCount() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let many = (0...100).map { Weight(id: Int64($0), createdAt: .now, mass: 75.0) }

        state.onWeigthLoaded(newWeights: many)
        let pageCountAfterLoad = state.pageCount

        // WHEN
        state.onObservedWeithsChenged(newWeights: many)

        // THEN
        #expect(state.pageCount == pageCountAfterLoad)
    }

    @Test func test_onObservedWeightsChanged_withManyItems_keepsCorrectWeightCount() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let many = (0...100).map { Weight(id: Int64($0), createdAt: .now, mass: 75.0) }

        state.onWeigthLoaded(newWeights: many)
        let expectedCount = WeightsState.pageSize * state.pageCount

        // WHEN
        state.onObservedWeithsChenged(newWeights: many)

        // THEN
        #expect(state.weights.count == expectedCount)
    }

    @Test func test_onObservedWeightsChanged_withEmptyArray_clearsState() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())
        let originalPageCount = state.pageCount

        // WHEN
        state.onObservedWeithsChenged(newWeights: [])

        // THEN
        #expect(state.pageCount == originalPageCount)
        #expect(state.weights.isEmpty)
    }

    @Test func test_onObservedWeightsChanged_withEmptyArray_removesNextCursor() {
        // GIVEN
        var state = WeightsState(weights: makeFullPageWeights())

        // WHEN
        state.onObservedWeithsChenged(newWeights: [])

        // THEN
        #expect(state.nextCursor == nil)
    }

    @Test func test_onObservedWeightsChanged_updatesWeightCount_onAdd() {
        // GIVEN
        let initial = makeWeights(count: 2)
        var state = WeightsState(weights: initial)
        let expanded = makeWeights(count: 3)

        // WHEN
        state.onObservedWeithsChenged(newWeights: expanded)

        // THEN
        #expect(state.weights.count == expanded.count)
    }

    @Test func test_onObservedWeightsChanged_updatesWeightCount_onRemove() {
        // GIVEN
        let initial = makeWeights(count: 2)
        var state = WeightsState(weights: initial)
        let reduced = makeWeights(count: 1)

        // WHEN
        state.onObservedWeithsChenged(newWeights: reduced)

        // THEN
        #expect(state.weights.count == reduced.count)
    }

    @Test func test_onObservedWeightsChanged_toProperCount_preservesNextCursor() {
        // GIVEN
        let initial = makeWeights(count: 2)
        var state = WeightsState(weights: initial)
        let expanded = makeWeights(count: 3)

        // WHEN
        state.onObservedWeithsChenged(newWeights: expanded)

        // THEN
        #expect(state.nextCursor != nil)
    }
}
