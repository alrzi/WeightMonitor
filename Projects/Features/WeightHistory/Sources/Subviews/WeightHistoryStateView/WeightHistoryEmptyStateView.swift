//
//  WeightHistoryEmptyStateView.swift
//  WeightHistory
//

import SwiftUI

struct WeightHistoryEmptyStateView: View {
    let onCreateWeight: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(
                String.featureLocalized("weightHistory.empty.title"),
                systemImage: "scalemass"
            )
        } description: {
            Text(String.featureLocalized("weightHistory.empty.description"))
        } actions: {
            Button(action: onCreateWeight) {
                Label(
                    String.featureLocalized("weightHistory.empty.action"),
                    systemImage: "plus"
                )
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(.primary)
        .padding(24)
    }
}
