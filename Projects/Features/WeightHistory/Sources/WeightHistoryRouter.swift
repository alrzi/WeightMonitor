//
//  WeightHistoryRouter.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 4/18/26.
//

import Foundation
import Domain

@MainActor
public protocol WeightHistoryRouter: AnyObject {
    func openCreateWeight()
    func openUpdateWeight(_ weight: Weight)
}
