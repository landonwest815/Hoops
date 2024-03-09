//
//  HoopSession.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftData

enum ShotType: String, Codable {
    case layups = "Layups"
    case freeThrows = "FTs"
    case midrange = "Midrange"
    case threePointers = "Threes"
    case deep = "Deep"
    case allShots = "All"
}

@Model
class HoopSession: Identifiable {
    var id = UUID()
    
    // Data
    var date: Date
    var makes: Int
    var length: Int
    var shotType: ShotType
    
    init(date: Date, makes: Int, length: Int, shotType: ShotType) {
        self.date = date
        self.makes = makes
        self.length = length
        self.shotType = shotType
    }
}
