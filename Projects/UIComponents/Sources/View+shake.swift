//
//  View+shake.swift
//  Tracker
//
//  Created by Александр Зиновьев on 26.03.2025.
//

import Foundation
import SwiftUI

public extension View {
    /// Добавляет анимацию тряски
    /// - Parameters:
    ///   - isOn: флаг, указывающий нужно ли выполнять анимацию
    ///   - amplitude: амплитуда анимации, по умолчанию - 5.0
    ///   - numberOfShakes: количество циклов тряски, по умолчанию - 3
    func shake(
        if isOn: Bool,
        withAmplitude amplitude: CGFloat = 5,
        times numberOfShakes: Int = 3
    ) -> some View {
        self
            .modifier(
                ShakeModifier(
                    amplitude: amplitude,
                    shakesCount: isOn ? numberOfShakes : 0
                )
                .animation(.linear)
            )
    }
}

struct ShakeModifier: GeometryEffect {
    private let amplitude: CGFloat
    private var position: CGFloat

    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }

    init(amplitude: CGFloat, shakesCount: Int) {
        self.amplitude = amplitude
        position = CGFloat(shakesCount)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let transform = CGAffineTransform(
            translationX: amplitude * sin(2 * .pi * position),
            y: 0
        )

        return ProjectionTransform(transform)
    }
}

struct ShakeModifier_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView()
    }

    struct PreviewView: View {
        @State var shouldShake = false

        var body: some View {
            Button(
                action: { shouldShake.toggle() },
                label: {
                    Text("Shake")
                }
            )
            .shake(if: shouldShake)
        }
    }
}
