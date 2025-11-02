//
//  WeightHistoryView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 02.05.2023.
//

import SwiftUI
import WeigthMonitorDomain

@MainActor
struct WeightHistoryView<ViewModel: WeightHistoryViewModelProtocol> {
    @ObservedObject private var viewModel: ViewModel

    @Environment(\.locale) private var locale

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension WeightHistoryView: View {
    var body: some View {
        ScrollView {
            if let weights = viewModel.weightsState?.weights {
                LazyVStack(spacing: 24) {
                    WeightHistoryChartView(weights: weights)

                    Section {
                        ForEach(Array(weights.enumerated()), id: \.element.id) { index, weight in
                            VStack {
                                WeightHistoryRow(
                                    weightFormatted: weight.weightMeasurement.formatted(),
                                    massDifferenceFormatted: weight.weightDifferenceMeasurement.map { $0.formatted() },
                                    createdAtFormatted: weight.createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .wide))
                                )
                                .transition(.opacity)
                                .onTapGesture { viewModel.onTap(at: index) }
                                .contextMenu {
                                    Button("Delete", action: { viewModel.onDeleteTap(at: index) })
                                }
                            }
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentItemIndex: index)
                            }
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("История")
                                .font(.headline)

                            WeightHistoryRow(
                                weightFormatted: "Вес",
                                massDifferenceFormatted: "Изменения",
                                createdAtFormatted: "Дата"
                            )

                            Divider()
                        }
                        .padding(.top, 16)
                        .background(Color(.systemBackground))
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .animation(.easeInOut, value: viewModel.weightsState)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack {
                Text("Монитор веса")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)

                if
                    let weightsState = viewModel.weightsState,
                    let first = weightsState.weights.first,
                    let weightDifferenceMeasurement = first.weightDifferenceMeasurement
                {
                    WeightInfoView(
                        weightFormatted: first.weightMeasurement.formatted(),
                        massDifferenceFormatted: weightDifferenceMeasurement.formatted(),
                        weightUnit: $viewModel.weightUnit
                    )
                }
            }
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
            Button(action: viewModel.onCreateNewWeight) {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(.blue, in: .circle)
            }
            .padding(16)
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

private struct WeightInfoView: View {
    let weightFormatted: String
    let massDifferenceFormatted: String
    
    @Binding var weightUnit: WeightUnit

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Текущий вес")
                    HStack {
                        Text(weightFormatted)
                        Text(massDifferenceFormatted)
                    }
                }
                
                Spacer(minLength: 0)
                
                Image(.weight)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.leading)
            
            Toggle(
                "Метрическая система",
                isOn: .init(
                    get: { weightUnit.isMetric },
                    set: { weightUnit = $0 ? .metric : .imperial }
                )
            )
            .padding()
        }
        .background(Color(.currentWeightBackground), in: .rect(cornerRadius: 12))
    }
}

private struct WeightHistoryRow: View {
    let weightFormatted: String
    let massDifferenceFormatted: String?
    let createdAtFormatted: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(weightFormatted)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let massDifferenceFormatted {
                Text(massDifferenceFormatted)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }

            Text(createdAtFormatted)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#if DEBUG
#Preview {
    WeightHistoryView(viewModel: ViewModel())
}

private final class ViewModel: WeightHistoryViewModelProtocol {
    var weightUnit: WeightUnit = .imperial
    var isNewWeightAdded: Bool = false
    var weightsState: WeightsState? = .init(weights: Weight.mockWeights)
    var route: WeightHistoryRoute?

    func onAppear() { }
    func onTap(at index: Int) { }
    func onCreateNewWeight() { }
    func onDeleteTap(at index: Int) { }
    func loadMoreIfNeeded(currentItemIndex index: Int) { }
    func reload() { }
}
#endif
