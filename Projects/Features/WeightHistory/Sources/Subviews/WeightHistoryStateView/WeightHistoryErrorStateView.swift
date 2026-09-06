//
//  WeightHistoryErrorStateView.swift
//  WeightHistory
//

import SwiftUI

struct WeightHistoryErrorStateView: View {
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(
                String.featureLocalized("weightHistory.error.title"),
                systemImage: "wifi.exclamationmark"
            )
        } description: {
            Text(String.featureLocalized("weightHistory.error.description"))
        } actions: {
            Button(action: onRetry) {
                Label(
                    String.featureLocalized("weightHistory.error.action"),
                    systemImage: "arrow.clockwise"
                )
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(.orange)
        .padding(24)
    }
}
