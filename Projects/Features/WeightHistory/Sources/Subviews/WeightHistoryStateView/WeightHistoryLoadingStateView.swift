//
//  WeightHistoryLoadingStateView.swift
//  WeightHistory
//

import SwiftUI

struct WeightHistoryLoadingStateView: View {
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .tint(.accentColor)
    }
}
