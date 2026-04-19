//
//  View+alert.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation
import SwiftUI

public extension View {
    func alert(model: Binding<AlertModel?>) -> some View {
        modifier(AlertBindingModifier(model: model))
    }
}
