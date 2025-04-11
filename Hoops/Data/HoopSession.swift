//
//  HoopSession.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftData

// MARK: - SessionType Enum

/// Represents the type of session performed.
enum SessionType: String, Codable, CaseIterable {
    case freestyle = "Freestyle"
    case challenge = "Challenge"
    case drill = "Drill"
}

// MARK: - ShotType Enum

/// Represents the type of shot that was attempted during a session.
enum ShotType: String, Codable, CaseIterable, Identifiable {
    case layups = "Layups"
    case freeThrows = "Free Throws"
    case midrange = "Midrange"
    case threePointers = "Threes"
    case deep = "Deep"
    case allShots = "All Shots"
    
    /// Use the enum case itself as the identifier.
    var id: Self { self }
    
    /// Returns a list of detailed shot names (or descriptors) for a given shot type.
    var shots: [String] {
        switch self {
        case .layups:
            return [
                "Left-Handed Layup",
                "Right-Handed Layup",
                "Floater",
                "Reverse Layup",
                "Finger Roll"
                // Additional shot descriptions are commented out for now.
            ]
        case .midrange:
            return [
                "Left Baseline Midrange",
                "Right Baseline Midrange",
                "Left Elbow Midrange",
                "Right Elbow Midrange",
                "Free Throw Line Midrange"
                // Other midrange variants are commented out.
            ]
        case .threePointers:
            return [
                "Left Corner Three",
                "Right Corner Three",
                "Left Wing Three",
                "Right Wing Three",
                "Top of the Key Three"
                // Additional three pointer variants are commented out.
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
            // For All Shots, aggregate the shots from all other cases.
            return ShotType.allCases
                .filter { $0 != .allShots }
                .flatMap { $0.shots }
        }
    }

    /// Custom decoding to handle legacy shot type names.
    /// For example, older data might use "FTs" to represent free throws.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "FTs": // Legacy value
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

// MARK: - GraphType Enum

/// Represents the metric types available for graphing session data.
enum GraphType: String, Codable, CaseIterable {
    case sessions = "Sessions"
    case makes = "Total Makes"
    case average = "Average Makes"
    case none = "N/A"
}

// MARK: - HoopSession Model

/// Represents a single session of hoops, including details about the session date, the number of successful shots,
/// the session duration (stored in seconds), and the types of shots and session performed.
@Model
class HoopSession: Identifiable {
    var id = UUID()
    
    // MARK: - Data Properties
    var date: Date
    var makes: Int
    var length: Int       // Session length in seconds.
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

// MARK: - Preview Data

extension HoopSession {
    /// Creates a preview ModelContainer populated with sample HoopSession data.
    /// Note: Currently generates sessions for the last 10 days.
    @MainActor
    static var preview: ModelContainer {
        // Create an in-memory ModelContainer for HoopSession.
        let container = try! ModelContainer(for: HoopSession.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let shotTypes: [ShotType] = [.layups, .freeThrows, .midrange, .threePointers, .deep, .allShots]
        let calendar = Calendar.current
        let today = Date()
        
        // Loop to generate sample sessions.
        // The loop comment originally mentioned 30 days; currently, it generates for 10 days.
        // You may wish to change 0..<10 to 0..<30 if you need 30 days of sample data.
        for dayOffset in 0..<10 {
            let sessionDate = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let sessionCount = Int.random(in: 1...3) // 1 to 3 sessions per day.
            
            for _ in 0..<sessionCount {
                let shotType = shotTypes.randomElement()!
                
                // **Skill Progression Scaling**: The further in the past, the lower the makes.
                // Here, progressFactor ranges from 1 (today) to ~0.7 (10 days ago).
                let progressFactor = Double(30 - dayOffset) / 30.0
                // Shot attempts (makes) increase over time; baseMakes gradually increases from 5 to ~30.
                let baseMakes = Int(5 + 25 * progressFactor)
                let variation = Int.random(in: -3...3)
                let makes = max(5, baseMakes + variation)
                
                // Session length increases over time.
                // NOTE: Length is in seconds. The comment has been updated accordingly (from 60 to ~180 seconds).
                let baseLength = Int(60 + 120 * progressFactor)
                let lengthVariation = Int.random(in: -15...15)
                let length = max(60, baseLength + lengthVariation)
                
                // Insert the sample session into the container’s main context.
                container.mainContext.insert(
                    HoopSession(date: sessionDate, makes: makes, length: length, shotType: shotType, sessionType: .freestyle)
                )
            }
        }
        
        return container
    }
}
