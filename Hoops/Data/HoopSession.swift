//
//  HoopSession.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftData

enum SessionType: String, Codable, CaseIterable {
    case freestyle = "Freestyle"
    case challenge = "Challenge"
    case drill = "Drill"
}

enum ShotType: String, Codable, CaseIterable, Identifiable {
    case layups = "Layups"
    case freeThrows = "Free Throws"
    case midrange = "Midrange"
    case threePointers = "Threes"
    case deep = "Deep"
    case allShots = "All Shots"
    
    var id: Self { self }  // Use the enum case itself as the identifier

    var shots: [String] {
        switch self {
        case .layups:
            return [
                "Left-Handed Layup",
                "Right-Handed Layup",
                "Floater",
                "Reverse Layup",
                "Finger Roll"
                //"Standard Layup",
                //"Euro Step Layup",
                //"Up-and-Under Layup",
                //"Circus Layup",
                //"Off-Hand Scoop Layup"
            ]
        case .midrange:
            return [
                "Left Baseline Midrange",
                "Right Baseline Midrange",
                "Left Elbow Midrange",
                "Right Elbow Midrange",
                "Free Throw Line Midrange",
//                "Fadeaway Mid-Range",
//                "Stepback Mid-Range",
//                "Pull-up Mid-Range",
//                "Bank Shot",
//                "Runner/Floater",
//                "Turnaround Jumper",
//                "One-Legged Fadeaway"
            ]
        case .threePointers:
            return [
                "Left Corner Three",
                "Right Corner Three",
                "Left Wing Three",
                "Right Wing Three",
                "Top of the Key Three",
//                "Stepback Three",
//                "Catch-and-Shoot Three",
//                "Pull-up Three",
//                "Transition Three"
            ]
        case .deep:
            return [
                "Left Deep Three",
                "Center Deep Three",
                "Right Deep Three"
            ]
        case .freeThrows:
            return ["Free Throw"]
        case .allShots:
            return ShotType.allCases
                .filter { $0 != .allShots }
                .flatMap { $0.shots }
        }
    }

    // Custom decoding to handle legacy data
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "FTs": // Old value
            self = .freeThrows
        default:
            if let validValue = ShotType(rawValue: rawValue) {
                self = validValue
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown ShotType: \(rawValue)")
            }
        }
    }
}


enum GraphType: String, Codable, CaseIterable {
    case sessions = "Sessions"
    case makes = "Total Makes"
    case average = "Average Makes"
    case none = "N/A"
}

@Model
class HoopSession: Identifiable {
    var id = UUID()
    
    // Data
    var date: Date
    var makes: Int
    var length: Int
    var shotType: ShotType
    var sessionType: SessionType
    
    init(date: Date, makes: Int, length: Int, shotType: ShotType, sessionType: SessionType = .freestyle) {
        self.date = date
        self.makes = makes
        self.length = length
        self.shotType = shotType
        self.sessionType = sessionType
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

                container.mainContext.insert(HoopSession(date: sessionDate, makes: makes, length: length, shotType: shotType, sessionType: .freestyle))
            }
        }
        
        return container
    }
}
