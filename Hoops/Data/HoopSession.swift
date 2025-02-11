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

        let shotTypes: [ShotType] = [.layups, .freeThrows, .midrange, .threePointers, .deep, .allShots]
        let calendar = Calendar.current
        let today = Date()

        for dayOffset in 0..<30 { // Generate for the last 30 days
            let sessionDate = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let sessionCount = Int.random(in: 1...3) // 1 to 3 sessions per day

            for _ in 0..<sessionCount {
                let shotType = shotTypes.randomElement()!

                // **Skill Progression Scaling**: The further in the past, the lower the makes.
                let progressFactor = Double(30 - dayOffset) / 30.0 // 0.03 (earliest) to 1.0 (today)
                
                // Shot attempts increase over time, but accuracy also improves
                let baseMakes = Int(5 + 25 * progressFactor) // Gradual increase from 5 to ~30
                let variation = Int.random(in: -3...3) // Small natural variation
                let makes = max(5, baseMakes + variation) // Ensure min makes of 5
                
                // Session length increases over time
                let baseLength = Int(60 + 120 * progressFactor) // Gradual increase from 60 to ~180 minutes
                let lengthVariation = Int.random(in: -15...15) // Small natural variation
                let length = max(60, baseLength + lengthVariation) // Ensure min session of 60 min

                container.mainContext.insert(HoopSession(date: sessionDate, makes: makes, length: length, shotType: shotType))
            }
        }
        
        return container
    }
}
