//
//  SessionsLogic.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import Foundation

/// Encapsulates all session‑related calculations, keeping business logic out of the views.
struct SessionsLogic {
    
    // MARK: - Aggregate Statistics

    static func stats(for sessions: [HoopSession]) -> (count: Int, totalMakes: Int, average: Double) {
        let count = sessions.count
        let totalMakes = sessions.reduce(0) { $0 + $1.makes }
        let totalTime = sessions.reduce(0) { $0 + $1.length }
        let average = totalTime > 0 ? Double(totalMakes) / Double(totalTime) * 60 : 0
        return (count, totalMakes, average)
    }
    
    static func calculateAllTimeAverage(for sessions: [HoopSession]) -> Double {
        stats(for: sessions).average
    }
    
    static func calculateTotalMakes(for sessions: [HoopSession]) -> Int {
        stats(for: sessions).totalMakes
    }
    
    static func calculateDaysHooped(for sessions: [HoopSession]) -> Int {
        let uniqueDays = Set(sessions.map { $0.date.startOfDay })
        return uniqueDays.count
    }

    static func calculateWeeklyStreak(from sessions: [HoopSession]) -> Int {
        let calendar = Calendar.current
        let weekStarts = Set(sessions.compactMap {
            calendar.dateInterval(of: .weekOfYear, for: $0.date)?.start
        })
        let sorted = weekStarts.sorted(by: >)
        guard let mostRecent = sorted.first else { return 0 }

        var streak = 1
        var previous = mostRecent

        for week in sorted.dropFirst() {
            if let expected = calendar.date(byAdding: .weekOfYear, value: -1, to: previous),
               calendar.isDate(expected, inSameDayAs: week) {
                streak += 1
                previous = week
            } else {
                break
            }
        }

        return streak
    }
    
    // MARK: - Test Data Generation
    
    static func generateRandomSession(on date: Date) -> HoopSession {
        let calendar = Calendar.current
        let now = Date()
        
        var dt = calendar.date(
            bySettingHour: calendar.component(.hour, from: now),
            minute: calendar.component(.minute, from: now),
            second: calendar.component(.second, from: now),
            of: date
        ) ?? date

        dt.addTimeInterval(Double.random(in: 0.001...0.999))

        return HoopSession(
            date: dt,
            makes: Int.random(in: 5...40),
            length: Int.random(in: 60...600),
            shotType: ShotType.allCases.randomElement() ?? .allShots,
            sessionType: SessionType.allCases.randomElement() ?? .freestyle
        )
    }

    static func updateStats(for sessions: [HoopSession]) -> (count: Int, totalMakes: Int, average: Double) {
        stats(for: sessions)
    }

    static func computeAccolades(for sessions: [HoopSession]) -> [Accolade] {
        let sessionsAccolade = Accolade(title: "Sessions", value: sessions.count, thresholds: (10, 25, 50), icon: "basketball.fill")
        let makesAccolade = Accolade(title: "Makes", value: calculateTotalMakes(for: sessions), thresholds: (200, 500, 1000), icon: "scope")
        let daysAccolade = Accolade(title: "Days Hooped", value: calculateDaysHooped(for: sessions), thresholds: (7, 30, 100), icon: "calendar")
        return [sessionsAccolade, makesAccolade, daysAccolade]
    }
}
