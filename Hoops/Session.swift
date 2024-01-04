//
//  Session.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import Foundation
import SwiftData

@Model
class Session {
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
