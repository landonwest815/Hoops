//
//  DateExtension.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
