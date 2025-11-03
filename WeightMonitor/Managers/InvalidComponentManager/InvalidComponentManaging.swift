//
//  InvalidComponentManaging.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation

/// Вспомогательная логика пометки компонентов ошибочными
///
/// Может использоваться для управления шейком полей из вьюмодели в SwiftUI вью
@MainActor
protocol InvalidComponentManaging<Component> {
    associatedtype Component: Equatable
    associatedtype InvalidComponentPublisher: Publisher<Component?, Never>

    /// Паблишер с помеченным ошибочным компонентом
    var invalidComponent: InvalidComponentPublisher { get }

    /// Помечает компонент ошибочным
    /// - Parameter component: Компонент, содержащий ошибку
    ///
    /// - Note: По истечению определенного времени ``invalidComponent`` будет снова сброшен в `nil`
    func markComponentInvalid(_ component: Component)
}
