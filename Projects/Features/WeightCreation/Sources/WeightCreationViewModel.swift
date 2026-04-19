//
//  WeightCreationViewModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 26.10.2025.
//

import Foundation
import UIComponents
import Domain

@MainActor
public protocol WeightCreationViewModelProtocol: ObservableObject {
    var selectedDate: Date { get set }
    var weightInput: String { get set }
    var buttonTitle: String { get }
    var alertModel: AlertModel? { get set }
    var dateRange: ClosedRange<Date> { get }
    var weightUnitFormatter: String { get }
    var isDatePickerVisible: Bool { get }
    var invalidComponent: WeightCreationInvalidComponent? { get }

    func onDateTap()
    func onCreateWeightTap()
}

public final class WeightCreationViewModel: WeightCreationViewModelProtocol {
    typealias InvalidComponent = WeightCreationInvalidComponent

    private let weightManager: any WeightManaging
    private let weightUnitManager: any WeightUnitManaging
    private let invalidComponentManager: any InvalidComponentManaging<WeightCreationInvalidComponent>
    private let input: WeightCreationInput
    private let onCompletion: @MainActor () -> Void

    public let weightUnitFormatter: String
    public let dateRange: ClosedRange<Date>
    public let buttonTitle: String

    @Published public private(set) var isDatePickerVisible = false
    @Published public private(set) var invalidComponent: WeightCreationInvalidComponent?

    @Published public var alertModel: AlertModel?
    @Published public var selectedDate: Date
    @Published public var weightInput: String

    public init(
        weightManager: some WeightManaging,
        weightUnitManager: some WeightUnitManaging,
        invalidComponentManager: some InvalidComponentManaging<WeightCreationInvalidComponent>,
        input: WeightCreationInput,
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

    public func onDateTap() {
        isDatePickerVisible = !isDatePickerVisible
    }

    public func onCreateWeightTap() {
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
                alertModel = .weightOperationFailed(isUpdate: input.isUpdate) { [weak self] in
                    self?.onCreateWeightTap()
                }
            }
        }
    }
}

// MARK: - Private

extension WeightCreationViewModel {
    fileprivate static func kilograms(from input: String, unit: UnitMass) -> Double? {
        guard let raw = input.toDoubleIfPossible() else {
            return nil
        }

        let measurement = Measurement(value: raw, unit: unit)
        return measurement.converted(to: .kilograms).value
    }
}

extension String {
    fileprivate func toDoubleIfPossible() -> Double? {
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

extension WeightCreationInput {
    fileprivate var selectedDate: Date {
        switch self {
        case .create: .now
        case .update(let weight): weight.createdAt
        }
    }

    fileprivate func weightInput(unit: WeightUnit) -> String {
        switch self {
        case .create: ""
        case .update(let weight):
            Measurement(value: weight.mass, unit: .kilograms)
                .converted(to: unit.toUnitMass())
                .value
                .formatted()
        }
    }

    fileprivate var buttonTitle: String {
        switch self {
        case .create: "Create"
        case .update: "Update"
        }
    }

    fileprivate var isUpdate: Bool {
        switch self {
        case .create: false
        case .update: true
        }
    }
}

extension AlertModel {
    fileprivate static func weightOperationFailed(isUpdate: Bool, retryHandler: @escaping () -> Void) -> AlertModel {
        let primary = Action.AlertButton(title: "OK")
        let secondary = Action.AlertButton(title: "Retry", handler: retryHandler)

        let title = isUpdate ? "Update failed" : "Create failed"
        let message =
            isUpdate
            ? "The weight could not be updated. Please try again."
            : "The weight could not be saved. Please try again."

        return AlertModel(
            title: title,
            message: message,
            action: .custom(.double(primary: primary, secondary: secondary))
        )
    }
}
