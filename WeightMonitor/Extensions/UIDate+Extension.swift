//
//  UIDate+Extension.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 07.05.2023.
//

import Foundation

extension Date {
    func todayOrOtherDayString() -> String {
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: self)
        }
    }
}
