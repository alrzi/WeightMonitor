//
//  WeightHistoryListView.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import SwiftUI
import WeigthMonitorDomain

struct WeightHistoryListView: View {
    let weights: [Weight]
    let weightUnit: WeightUnit
    let onTapAtIndex: (Int) -> Void
    let onDeleteAtIndex: (Int) -> Void
    let onWeightAppear: (Int) -> Void

    var body: some View {
        Section {
            ForEach(Array(weights.enumerated()), id: \.element.id) { index, weight in
                VStack {
                    WeightHistoryRow(
                        weightFormatted: weight.weightFormatted(to: weightUnit),
                        massDifferenceFormatted: weight.massDifferenceFormatted(to: weightUnit),
                        createdAtFormatted: weight.createdAtFormatted,
                    )
                    .transition(.opacity)
                    .onTapGesture { onTapAtIndex(index) }
                    .contextMenu {
                        Button("Delete", action: { onDeleteAtIndex(index) })
                    }
                }
                .onAppear { onWeightAppear(index) }
            }
        } header: {
            VStack(alignment: .leading) {
                Text("История")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 16)

                WeightHistoryRow(
                    weightFormatted: "Вес",
                    massDifferenceFormatted: "Изменения",
                    createdAtFormatted: "Дата"
                )

                Divider()
            }
            .padding(.top, 16)
        }
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
        .padding(8)
        .background(.background)
    }
}

#Preview {
    WeightHistoryListView(
        weights: [],
        weightUnit: .metric,
        onTapAtIndex: { _ in },
        onDeleteAtIndex: { _ in },
        onWeightAppear: { _ in }
    )
}
