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

        let today = Date()
        let yesterday = Date(timeInterval: -86400, since: today)
        let twoDaysAgo = Date(timeInterval: -172800, since: today)

        container.mainContext.insert(HoopSession(date: twoDaysAgo, makes: 15, length: 120, shotType: .allShots))
        container.mainContext.insert(HoopSession(date: twoDaysAgo, makes: 10, length: 100, shotType: .threePointers))
        container.mainContext.insert(HoopSession(date: twoDaysAgo, makes: 8, length: 80, shotType: .freeThrows))

        container.mainContext.insert(HoopSession(date: yesterday, makes: 12, length: 110, shotType: .midrange))
        container.mainContext.insert(HoopSession(date: yesterday, makes: 18, length: 130, shotType: .layups))
        container.mainContext.insert(HoopSession(date: yesterday, makes: 14, length: 90, shotType: .deep))

        container.mainContext.insert(HoopSession(date: today, makes: 20, length: 140, shotType: .allShots))
        container.mainContext.insert(HoopSession(date: today, makes: 16, length: 125, shotType: .freeThrows))
        container.mainContext.insert(HoopSession(date: today, makes: 22, length: 150, shotType: .threePointers))

        return container
    }
}
