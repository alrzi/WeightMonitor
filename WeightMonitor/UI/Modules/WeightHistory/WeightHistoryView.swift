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
    @Environment(\.colorScheme) private var colorScheme

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension WeightHistoryView: View {
    var body: some View {
        NavigationStack {
            Group {
                if let weights = viewModel.weightsState?.weights {
                    if let first = weights.first {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                WeightInfoView(
                                    weightFormatted: first.weightFormatted(to: viewModel.weightUnit),
                                    massDifferenceFormatted: first.massDifferenceFormatted(to: viewModel.weightUnit),
                                    weightUnit: $viewModel.weightUnit,
                                )

                                WeightHistoryChartView(
                                    weights: weights,
                                    weightUnit: viewModel.weightUnit,
                                )

                                WeightHistoryListView(
                                    weights: weights,
                                    weightUnit: viewModel.weightUnit,
                                    onTapAtIndex: viewModel.onTap,
                                    onDeleteAtIndex: viewModel.onDeleteTap,
                                    onWeightAppear: viewModel.onWeightAppear
                                )
                            }
                            .padding(.horizontal, colorScheme == .light ? 6 : 0)
                            .animation(.easeInOut, value: viewModel.weightsState)
                        }
                        .scrollIndicators(.hidden)
                    }
                    else {
                        ZStack {
                            Text("Пока пусто")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
                else {
                    ZStack {
                        ProgressView()
                            .tint(.blue)
                            .controlSize(.large)
                    }
                }
            }
            .navigationTitle("Монитор веса")
            .navigationBarTitleDisplayMode(.inline)
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
            Button(action: viewModel.onCreateNewWeight) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 18, height: 18)
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
    let massDifferenceFormatted: String?

    @Binding var weightUnit: WeightUnit

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Текущий вес")
                    HStack {
                        Text(weightFormatted)
                        Text(massDifferenceFormatted ?? 0.formatted())
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
            .tint(.orange)
            .padding()
        }
        .background(.blue.opacity(0.5), in: .rect(cornerRadius: 12))
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
    func onWeightAppear(at index: Int) { }
}
#endif
