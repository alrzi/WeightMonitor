//
//  WeightHistoryLoadState.swift
//  WeightHistory
//

import Foundation

public enum WeightHistoryLoadState: Equatable {
    case loading
    case content
    case empty
    case failure
}
