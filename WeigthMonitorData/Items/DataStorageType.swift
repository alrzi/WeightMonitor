//
//  DataStorageType.swift
//  WeigthMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import DataStorage

enum DataStorageType: DataStorageTypeProtocol {
    case standart

    static var `default`: DataStorageType { .standart }
}
