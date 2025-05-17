//
//  HoopSession.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import SwiftUI
import SwiftData

enum SessionType: String, Codable, CaseIterable {
    case freestyle   = "Freestyle"
    case challenge   = "Challenge"
    case drill       = "Drill"
}

enum ShotType: String, Codable, CaseIterable, Identifiable {
    case layups        = "Layups"
    case freeThrows    = "Free Throws"
    case midrange      = "Midrange"
    case threePointers = "Threes"
    case deep          = "Deep"
    case allShots      = "All Shots"

    var id: Self { self }
    var displayName: String { rawValue }

    var color: Color {
        switch self {
        case .layups:         return .red
        case .freeThrows:     return .blue
        case .midrange:       return .blue
        case .threePointers:  return .green
        case .deep:           return .purple
        case .allShots:       return .orange
        }
    }

    var shots: [String] {
        switch self {
        case .layups:
            ["Left-Handed Layup", "Right-Handed Layup", "Floater", "Reverse Layup", "Finger Roll"]
        case .midrange:
            ["Left Baseline", "Right Baseline", "Left Elbow", "Right Elbow", "Free Throw Line"]
        case .threePointers:
            ["Left Corner Three", "Right Corner Three", "Left Wing Three", "Right Wing Three", "Top of the Key Three"]
        case .deep:
            ["Left Deep Three", "Center Deep Three", "Right Deep Three"]
        case .freeThrows:
            Array(repeating: "Free Throw", count: 5)
        case .allShots:
            ShotType.allCases
                .filter { $0 != .allShots }
                .flatMap { $0.shots }
        }
    }

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "FTs":
            self = .freeThrows
        default:
            guard let value = ShotType(rawValue: raw) else {
                throw DecodingError.dataCorruptedError(
                    in: try decoder.singleValueContainer(),
                    debugDescription: "Unknown ShotType: \(raw)"
                )
            }
            self = value
        }
    }
}

enum GraphType: String, Codable, CaseIterable {
    case sessions = "Sessions"
    case makes    = "Total Makes"
    case average  = "Average Makes"
    case none     = "N/A"
}

@Model
class HoopSession: Identifiable {
    var id = UUID()
    var date: Date
    var makes: Int
    var length: Int
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

        for dayOffset in 0..<10 {
            let sessionDate = cal.date(byAdding: .day, value: -dayOffset, to: today)!
            let sessionCount = Int.random(in: 1...3)

            for _ in 0..<sessionCount {
                let shot = types.randomElement()!
                let factor = Double(30 - dayOffset) / 30
                let makes = max(5, Int(5 + 25 * factor) + Int.random(in: -3...3))
                let length = max(60, Int(60 + 120 * factor) + Int.random(in: -15...15))

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
