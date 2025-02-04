//
//  HoopSession.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftData

enum ShotType: String, Codable, CaseIterable {
    case layups = "Layups"
    case freeThrows = "FTs"
    case midrange = "Midrange"
    case threePointers = "Threes"
    case deep = "Deep"
    case allShots = "All Shots"
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

extension HoopSession {
    // Create a static property that returns a ModelContainer
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: HoopSession.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
        container.mainContext.insert(HoopSession(date: Date(timeInterval: -86400, since: .now), makes: 15, length: 120, shotType: .allShots))
        container.mainContext.insert(HoopSession(date: Date(timeInterval: -86400, since: .now), makes: 12, length: 120, shotType: .allShots))
        container.mainContext.insert(HoopSession(date: Date(timeInterval: -86400, since: .now), makes: 17, length: 120, shotType: .allShots))

        return container
    }
}
