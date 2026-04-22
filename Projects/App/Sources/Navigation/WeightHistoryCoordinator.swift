//
//  WeightHistoryCoordinator.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 18.04.2026.
//

import Foundation
import SwiftUI
import WeightHistory
import UIComponents
import Domain

@MainActor
@Observable
final class WeightHistoryCoordinator: WeightHistoryRouter {
    enum Route: Identifiable {
        case create
        case update(Weight)

        var id: String {
            switch self {
            case .create: "create"
            case .update(let weight): weight.id.map { String($0) } ?? "update"
            }
        }
    }

    var route: Route?

    func openCreateWeight() {
        route = .create
    }

    func openUpdateWeight(_ weight: Domain.Weight) {
        route = .update(weight)
    }

    func dismiss() {
        route = nil
    }
}
