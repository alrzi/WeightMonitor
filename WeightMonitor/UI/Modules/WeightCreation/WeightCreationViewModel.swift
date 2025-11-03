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
    private let locale: Locale
    private let input:  WeightCreationInput
    private let onCompletion: @MainActor () -> Void

    let weightUnitFormatter: String

    @Published private(set) var isDatePickerVisible = false
    @Published private(set) var invalidComponent: InvalidComponent?

    @Published var selectedDate: Date
    @Published var weightInput: String

    init(
        weightManager: any WeightManaging,
        weightUnitManager: any WeightUnitManaging,
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        locale: Locale,
        input:  WeightCreationInput,
        onCompletion: @MainActor @escaping () -> Void
    ) {
        self.weightManager = weightManager
        self.weightUnitManager = weightUnitManager
        self.invalidComponentManager = invalidComponentManager
        self.locale = locale
        self.input = input
        self.onCompletion = onCompletion

        selectedDate = input.selectedDate
        weightInput = input.weightInput(unit: weightUnitManager.lastSelectedWeightUnit)
        weightUnitFormatter = weightUnitManager.lastSelectedWeightUnit.toUnitMass().symbol

        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }

    func onDateTap() {
        isDatePickerVisible = !isDatePickerVisible
    }

    func onCreateWeightTap() {
        if let weightInput = Double(weightInput) {
            let weightMeassurement = Measurement<UnitMass>(
                value: weightInput,
                unit: weightUnitManager.lastSelectedWeightUnit.toUnitMass()
            )

            Task {
                do {
                    switch input {
                    case .create:
                        let weight = Weight(
                            createdAt: selectedDate,
                            mass: weightMeassurement.converted(to: .kilograms).value
                        )

                        try await weightManager.create(weight: weight)

                    case .update(let weightToUpdate):
                        let weight = Weight(
                            id: weightToUpdate.id,
                            createdAt: selectedDate,
                            mass: weightMeassurement.converted(to: .kilograms).value
                        )

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
