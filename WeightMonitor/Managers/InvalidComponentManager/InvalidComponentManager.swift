//
//  InvalidComponentManager.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 26.10.2025.
//

import Combine
import Foundation

final class InvalidComponentManager<Component: Equatable>: InvalidComponentManaging {
    private let mutableInvalidComponent = CurrentValueSubject<Component?, Never>(nil)
    private var invalidComponentCancellable: AnyCancellable?

    private let duration: TimeInterval

    var invalidComponent: some Publisher<Component?, Never> { mutableInvalidComponent }

    init(duration: TimeInterval = 0.5) {
        self.duration = duration
    }

    func markComponentInvalid(_ component: Component) {
        mutableInvalidComponent.value = component

        invalidComponentCancellable = Timer.publish(every: duration, on: .main, in: .default)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                self?.mutableInvalidComponent.value = nil
            }
    }
}
