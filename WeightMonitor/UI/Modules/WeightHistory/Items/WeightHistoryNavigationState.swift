//
//  WeightHistoryNavigationState.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 26.10.2025.
//

import Foundation
import WeigthMonitorDomain

@MainActor
protocol WeightHistoryNavigationState: ObservableObject {
    var route: WeightHistoryRoute? { get set }
}

enum WeightHistoryRoute: Identifiable {
    case create(onCompletion: @MainActor () -> Void)
    case update(weight: Weight, onCompletion: @MainActor () -> Void)

    var id: ID {
        switch self {
        case .create: .create
        case .update: .update
        }
    }

    enum ID {
        case create
        case update
    }
}
