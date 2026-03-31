//
//  AlertModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

struct AlertModel {
    enum Action {
        enum CustomActions {
            case double(primary: AlertButton, secondary: AlertButton)
        }

        struct AlertButton {
            let title: String
            var handler: () -> Void = { }
        }

        case cancel(AlertButton)
        case destructive(AlertButton)
        case custom(CustomActions)
    }

    var title: String = "Error"
    var message: String = "An unknown error occurred."
    var action: Action
}
