//
//  HoopSession.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftData

// MARK: - SessionType

enum SessionType: String, Codable, CaseIterable {
    case freestyle = "Freestyle"
    case challenge = "Challenge"
    case drill     = "Drill"
}


// MARK: - ShotType

enum ShotType: String, Codable, CaseIterable, Identifiable {
    case layups       = "Layups"
    case freeThrows   = "Free Throws"
    case midrange     = "Midrange"
    case threePointers = "Threes"
    case deep         = "Deep"
    case allShots     = "All Shots"
    
    var id: Self { self }
    
    var shots: [String] {
        switch self {
        case .layups:
            return ["Left-Handed Layup", "Right-Handed Layup", "Floater", "Reverse Layup", "Finger Roll"]
        case .midrange:
            return ["Left Baseline Midrange", "Right Baseline Midrange", "Left Elbow Midrange", "Right Elbow Midrange", "Free Throw Line Midrange"]
        case .threePointers:
            return ["Left Corner Three", "Right Corner Three", "Left Wing Three", "Right Wing Three", "Top of the Key Three"]
        case .deep:
            return ["Left Deep Three", "Center Deep Three", "Right Deep Three"]
        case .freeThrows:
            return Array(repeating: "Free Throw", count: 5)
        case .allShots:
            return ShotType.allCases
                .filter { $0 != .allShots }
                .flatMap { $0.shots }
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case "FTs": self = .freeThrows
        default:
            guard let val = ShotType(rawValue: raw) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown ShotType: \(raw)"
                )
            }
            self = val
        }
    }
}


// MARK: - GraphType

enum GraphType: String, Codable, CaseIterable {
    case sessions = "Sessions"
    case makes    = "Total Makes"
    case average  = "Average Makes"
    case none     = "N/A"
}


// MARK: - HoopSession Model

@Model
class HoopSession: Identifiable {
    var id = UUID()
    var date: Date
    var makes: Int
    var length: Int              // seconds
    var shotType: ShotType
    var sessionType: SessionType
    
    init(
        date: Date,
        makes: Int,
        length: Int,
        shotType: ShotType,
        sessionType: SessionType = .freestyle
    ) {
        self.date = date
        self.makes = makes
        self.length = length
        self.shotType = shotType
        self.sessionType = sessionType
    }
}


// MARK: - Preview Data

extension HoopSession {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: HoopSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let types: [ShotType] = [.layups, .freeThrows, .midrange, .threePointers, .deep, .allShots]
        let cal = Calendar.current
        let today = Date()
        
        // Generates 10 days of sample sessions
        for dayOffset in 0..<10 {
            let sessionDate = cal.date(byAdding: .day, value: -dayOffset, to: today)!
            let sessionCount = Int.random(in: 1...3)
            
            for _ in 0..<sessionCount {
                let shot = types.randomElement()!
                let factor = Double(30 - dayOffset) / 30.0
                let baseMakes = Int(5 + 25 * factor)
                let makes = max(5, baseMakes + Int.random(in: -3...3))
                let baseLen = Int(60 + 120 * factor)
                let length = max(60, baseLen + Int.random(in: -15...15))
                
                container.mainContext.insert(
                    HoopSession(
                        date: sessionDate,
                        makes: makes,
                        length: length,
                        shotType: shot
                    )
                )
            }
        }
        
        return container
    }
}
