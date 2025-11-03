//
//  WeightCreationViewModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 26.10.2025.
//

import Foundation
import WeigthMonitorDomain

@MainActor
protocol WeightCreationViewModelProtocol: ObservableObject {
    var selectedDate: Date { get set }
    var weightInput: String { get set }
    var dateRange: ClosedRange<Date> { get }
    var weightUnitFormatter: String { get }
    var isDatePickerVisible: Bool { get }
    var invalidComponent: WeightCreationInvalidComponent? { get }

    func onDateTap()
    func onCreateWeightTap()
}

final class WeightCreationViewModel: WeightCreationViewModelProtocol {
    typealias InvalidComponent = WeightCreationInvalidComponent

    private let weightManager: any WeightManaging
    private let weightUnitManager: any WeightUnitManaging
    private let invalidComponentManager: any InvalidComponentManaging<InvalidComponent>
    private let input:  WeightCreationInput
    private let onCompletion: @MainActor () -> Void

    let weightUnitFormatter: String
    let dateRange: ClosedRange<Date>

    @Published private(set) var isDatePickerVisible = false
    @Published private(set) var invalidComponent: InvalidComponent?

    @Published var selectedDate: Date
    @Published var weightInput: String

    init(
        weightManager: any WeightManaging,
        weightUnitManager: any WeightUnitManaging,
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        input:  WeightCreationInput,
        onCompletion: @MainActor @escaping () -> Void
    ) {
        self.weightManager = weightManager
        self.weightUnitManager = weightUnitManager
        self.invalidComponentManager = invalidComponentManager
        self.input = input
        self.onCompletion = onCompletion

        selectedDate = input.selectedDate
        dateRange = Date.distantPast...Date.now
        weightInput = input.weightInput(unit: weightUnitManager.lastSelectedWeightUnit)
        weightUnitFormatter = weightUnitManager.lastSelectedWeightUnit.toUnitMass().symbol

        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }

    func onDateTap() {
        isDatePickerVisible = !isDatePickerVisible
    }

    func onCreateWeightTap() {
        if let mass = Self.double(from: weightInput) {
            let unit = weightUnitManager.lastSelectedWeightUnit.toUnitMass()
            let mass = Measurement<UnitMass>(value: mass, unit: unit)
                .converted(to: .kilograms)
                .value

            Task {
                do {
                    switch input {
                    case .create:
                        let weight = Weight(createdAt: selectedDate, mass: mass)
                        try await weightManager.create(weight: weight)

                    case .update(let weight):
                        let weight = Weight(id: weight.id, createdAt: selectedDate, mass: mass)
                        try await weightManager.update(weight: weight)
                    }

                    onCompletion()
                }
                catch {
                    
                }
            }
        }
        else {
            invalidComponentManager.markComponentInvalid(.incorrectWeight)
        }
    }
}

// MARK: - Private

private extension WeightCreationViewModel {
    static func double(from string: String) -> Double? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return nil }

        if let number = NumberFormatter.weightFormatter.number(from: trimmed) {
            return number.doubleValue
        }

        let dotReplaced = trimmed.replacingOccurrences(of: ",", with: ".")

        if let number = NumberFormatter.dotOnlyNumberFormatter.number(from: dotReplaced) {
            return number.doubleValue
        }

        return nil
    }
}

private extension WeightCreationInput {
    var selectedDate: Date {
        switch self {
        case .create: .now
        case .update(let weight): weight.createdAt
        }
    }

    func weightInput(unit: WeightUnit) -> String {
        switch self {
        case .create: ""
        case .update(let weight): weight.weightFormatted(to: unit)
        }
    }
}
