//
//  WeightCreationView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 26.10.2025.
//

import Foundation
import SwiftUI
import WeigthMonitorDomain

@MainActor
struct WeightCreationView<ViewModel: WeightCreationViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension WeightCreationView: View {
    var body: some View {
        VStack {
            Text("Добавить вес")
                .font(.largeTitle)
                .padding(.top, 24)

            Spacer()

            HStack {
                Text("Дата")

                Spacer()

                Text(viewModel.selectedDate.todayOrOtherDayString())
                    .foregroundStyle(.blue)

                Image(systemName: "chevron.up")
                    .rotationEffect(.degrees(viewModel.isDatePickerVisible ? 0 : -180))
                    .foregroundStyle(.blue)
            }
            .onTapGesture(perform: viewModel.onDateTap)

            if viewModel.isDatePickerVisible {
                VStack {
                    Divider()

                    DatePicker(
                        "",
                        selection: $viewModel.selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .transition(.scale.combined(with: .opacity))
            }

            Divider()

            HStack {
                TextField("Enter weight", text: $viewModel.weightInput)
                    .keyboardType(.decimalPad)
                    .font(.largeTitle)

                Text(viewModel.weightUnitFormatter)
                    .foregroundStyle(.gray)
            }
            .shake(if: viewModel.invalidComponent == .incorrectWeight)

            Divider()

            Spacer()
        }
        .animation(.linear, value: viewModel.isDatePickerVisible)
        .padding(.horizontal, 24)
        .safeAreaInset(edge: .bottom) {
            Button("Enter", action: viewModel.onCreateWeightTap)
                .buttonStyle(.bordered)
                .padding(16)
        }
    }
}

#if DEBUG
#Preview {
    WeightCreationView(viewModel: ViewModel())
}

private final class ViewModel: WeightCreationViewModelProtocol {
    @Published var selectedDate: Date = .now
    @Published var isDatePickerVisible = false
    var weightInput: String = "12"
    var weightUnitFormatter: String = "kg"
    var invalidComponent: WeightCreationInvalidComponent?

    init() { }

    func onDateTap() {
        isDatePickerVisible = !isDatePickerVisible
    }

    func onCreateWeightTap() { }
}
#endif
