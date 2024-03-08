//
//  HoopSession.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftData

@Model
class HoopSession {
    // Data
    var date: Date
    var makes: Int
    var length: Int
    
    init(date: Date, makes: Int, length: Int) {
        self.date = date
        self.makes = makes
        self.length = length
    }
    
}
