//
//  Date+todayOrOtherDayString.swift
//  WeightMonitor
//
//  Created by Александр Зиновьев on 07.05.2023.
//

import Foundation

extension Date {
    func todayOrOtherDayString(calendar: Calendar = .autoupdatingCurrent) -> String {
        if calendar.isDateInToday(self) {
            "Today"
        }
        else if calendar.isDateInYesterday(self) {
            "Yesterday"
        }
        else {
            self.formatted(date: .abbreviated, time: .shortened)
        }
    }
}
