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

    @FocusState private var isFocused: Bool

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension WeightCreationView: View {
    var body: some View {
        VStack {
            Text("Ввод веса")
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
                        in: viewModel.dateRange,
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
                    .autocorrectionDisabled()
                    .font(.largeTitle)
                    .focused($isFocused)

                Text(viewModel.weightUnitFormatter)
                    .foregroundStyle(.gray)
            }
            .shake(if: viewModel.invalidComponent == .incorrectWeight)

            Divider()

            Spacer()
        }
        .animation(.linear, value: viewModel.isDatePickerVisible)
        .padding(.horizontal, 24)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    isFocused = false
                }
            }            
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: viewModel.onCreateWeightTap) {
                Text("Добавить вес")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 24)
        }
    }
}

#if DEBUG
#Preview {
    WeightCreationView(viewModel: ViewModel())
}

private final class ViewModel: WeightCreationViewModelProtocol {
    @Published var selectedDate: Date = .now
    @Published var weightInput: String = "12"
    @Published private(set) var isDatePickerVisible = false
    let weightUnitFormatter: String = "kg"
    let invalidComponent: WeightCreationInvalidComponent? = nil
    let dateRange: ClosedRange<Date> = .distantPast...Date.now

    init() { }

    func onDateTap() {
        isDatePickerVisible = !isDatePickerVisible
    }

    func onCreateWeightTap() { }
}
#endif
