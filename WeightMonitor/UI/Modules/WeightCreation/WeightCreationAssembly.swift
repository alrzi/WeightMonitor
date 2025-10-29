//
//  WeightCreationAssembly.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
import SwiftUI
import WeigthMonitorDomain

struct WeightCreationAssembly {
    let weightManager: any WeightManaging
    let locale: Locale

    @MainActor
    func assemble(
        input:  WeightCreationInput,
        onCompletion: @MainActor @escaping () -> Void
    ) -> some View {
        let viewModel = WeightCreationViewModel(
            weightManager: weightManager,
            locale: locale,
            input: input,
            onCompletion: onCompletion
        )

        let view = WeightCreationView(viewModel: viewModel)

        return view
    }
}
