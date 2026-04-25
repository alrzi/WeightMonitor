//
//  AlertModel.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

public struct AlertModel {
    public var title: String = "Error"
    public var message: String = "An unknown error occurred."
    public var action: Action

    public init(title: String = "Error", message: String = "An unknown error occurred.", action: Action) {
        self.title = title
        self.message = message
        self.action = action
    }

    public enum Action {
        case cancel(AlertButton)
        case destructive(AlertButton)
        case custom(CustomActions)

        public enum CustomActions {
            case double(primary: AlertButton, secondary: AlertButton)
        }

        public struct AlertButton {
            public let title: String
            public var handler: () -> Void = {}

            public init(title: String, handler: @escaping () -> Void = {}) {
                self.title = title
                self.handler = handler
            }
        }
    }
}
