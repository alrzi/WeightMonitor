//
//  WeigthHistoryNavigator.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 26.10.2025.
//

import Foundation
import SwiftUI

@MainActor
struct WeigthHistoryNavigator<Content: View, NavigationState: WeightHistoryNavigationState> {
    private let weightCreationAssembly: WeightCreationAssembly
    private let content: Content

    @ObservedObject private var navigationState: NavigationState

    init(
        weightCreationAssembly: WeightCreationAssembly,
        navigationState: NavigationState,
        content: () -> Content
    ) {
        self.weightCreationAssembly = weightCreationAssembly
        self.navigationState = navigationState
        self.content = content()
    }
}

extension WeigthHistoryNavigator: View {
    var body: some View {
        content
            .sheet(item: $navigationState.route) { route in
                switch route {
                case .create(let onCompletion):
                    weightCreationAssembly.assemble(input: .create, onCompletion: onCompletion)

                case .update(let weight, let onCompletion):
                    weightCreationAssembly.assemble(input: .update(weight), onCompletion: onCompletion)
                }
            }
    }
}
