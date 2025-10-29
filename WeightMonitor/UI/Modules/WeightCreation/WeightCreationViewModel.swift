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
        invalidComponentManager: some InvalidComponentManaging<InvalidComponent> = InvalidComponentManager(),
        locale: Locale,
        input:  WeightCreationInput,
        onCompletion: @MainActor @escaping () -> Void
    ) {
        self.weightManager = weightManager
        self.invalidComponentManager = invalidComponentManager
        self.locale = locale
        self.input = input
        self.onCompletion = onCompletion

        selectedDate = input.selectedDate
        weightInput = input.weightInput(locale: locale)
        weightUnitFormatter = locale.unitMass.symbol

        invalidComponentManager.invalidComponent.assign(to: &$invalidComponent)
    }

    func onDateTap() {
        isDatePickerVisible = !isDatePickerVisible
    }

    func onCreateWeightTap() {
        if let weightInput = Double(weightInput) {
            let weightMeassurement = Measurement<UnitMass>(value: weightInput, unit: locale.unitMass)

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

    func weightInput(locale: Locale) -> String {
        switch self {
        case .create: ""
        case .update(let weight): weight.weightMeasurement.converted(to: locale.unitMass).value.formatted()
        }
    }
}
