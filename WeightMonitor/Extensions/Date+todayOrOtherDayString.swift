//
//  Date+todayOrOtherDayString.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 07.05.2023.
//

import Foundation

extension Date {
    func todayOrOtherDayString() -> String {
        if Calendar.current.isDateInToday(self) {
            "Today"
        }
        else {
            self.formatted(date: .abbreviated, time: .shortened)
        }
    }
}
