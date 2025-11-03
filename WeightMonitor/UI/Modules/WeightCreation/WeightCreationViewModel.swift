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
    var buttonTitle: String { get }
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
    private let input: WeightCreationInput
    private let onCompletion: @MainActor () -> Void

    let weightUnitFormatter: String
    let dateRange: ClosedRange<Date>
    let buttonTitle: String

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
        buttonTitle = input.buttonTitle
        weightInput = input.weightInput(unit: weightUnitManager.lastSelectedWeightUnit)
        weightUnitFormatter = weightUnitManager.lastSelectedWeightUnit.toUnitMass().symbol

        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }

    func onDateTap() {
        isDatePickerVisible = !isDatePickerVisible
    }

    func onCreateWeightTap() {
        let unit = weightUnitManager.lastSelectedWeightUnit.toUnitMass()

        guard let massKg = Self.kilograms(from: weightInput, unit: unit) else {
            invalidComponentManager.markComponentInvalid(.incorrectWeight)
            return
        }

        Task {
            do {
                switch input {
                case .create:
                    let weight = Weight(createdAt: selectedDate, mass: massKg)
                    try await weightManager.create(weight: weight)

                case .update(let weight):
                    let weight = Weight(id: weight.id, createdAt: selectedDate, mass: massKg)
                    try await weightManager.update(weight: weight)
                }

                onCompletion()
            }
            catch {

            }
        }
    }
}

// MARK: - Private

private extension WeightCreationViewModel {
    static func kilograms(from input: String, unit: UnitMass) -> Double? {
        guard let raw = input.toDoubleIfPossible() else {
            return nil
        }

        let measurement = Measurement(value: raw, unit: unit)
        return measurement.converted(to: .kilograms).value
    }
}

private extension String {
    func toDoubleIfPossible() -> Double? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)

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
        case .update(let weight): Measurement(value: weight.mass, unit: .kilograms)
                .converted(to: unit.toUnitMass())
                .value
                .formatted()
        }
    }

    var buttonTitle: String {
        switch self {
        case .create: "Create"
        case .update: "Update"
        }
    }
}
