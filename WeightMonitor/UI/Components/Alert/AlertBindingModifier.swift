//
//  AlertBindingModifier.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 03.11.2025.
//

import Foundation
import SwiftUI

struct AlertBindingModifier: ViewModifier {
    @Binding var model: AlertModel?

    func body(content: Content) -> some View {
        content
            .alert(
                model?.title ?? "Error",
                isPresented: .init(
                    get: {
                        model != nil
                    },
                    set: {
                        if !$0 {
                            model = nil
                        }
                    }
                ),
                presenting: model,
                actions: {  data in
                    switch data.action {
                    case .cancel(let button):
                        Button(button.title, role: .cancel) {
                            button.handler()
                            model = nil
                        }

                    case .destructive(let button):
                        Button(button.title, role: .destructive) {
                            button.handler()
                            model = nil
                        }

                    case .custom(let action):
                        switch action {
                        case .double(let primary, let secondary):
                            Button(primary.title) {
                                primary.handler()
                                model = nil
                            }
                            Button(secondary.title) {
                                secondary.handler()
                                model = nil
                            }
                        }
                    }
                },
                message: { data in
                    Text(data.message)
                }
            )
    }
}
