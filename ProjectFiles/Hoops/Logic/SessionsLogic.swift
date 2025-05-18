//
//  SessionsLogic.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import Foundation

struct SessionsLogic {
    static func stats(for sessions: [HoopSession]) -> (count: Int, totalMakes: Int, average: Double) {
        let count = sessions.count
        let totalMakes = sessions.reduce(0) { $0 + $1.makes }
        let totalTime = sessions.reduce(0) { $0 + $1.length }
        let average = totalTime > 0
            ? Double(totalMakes) / Double(totalTime) * 60
            : 0
        return (count, totalMakes, average)
    }

    static func calculateAllTimeAverage(for sessions: [HoopSession]) -> Double {
        stats(for: sessions).average
    }

    static func calculateTotalMakes(for sessions: [HoopSession]) -> Int {
        stats(for: sessions).totalMakes
    }

    static func calculateDaysHooped(for sessions: [HoopSession]) -> Int {
        Set(sessions.map { $0.date.startOfDay }).count
    }

    static func calculateWeeklyStreak(from sessions: [HoopSession]) -> Int {
        let calendar = Calendar.current

        // 1) Find the start of *this* week.
        guard let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return 0
        }

        // 2) If there's at least one shot so far *this* week, include it.
        var streak = sessions.contains { $0.date >= thisWeekStart }
            ? 1
            : 0

        // 3) Now walk backwards from *last* week (i.e. thisWeekStart - 1 week).
        var weekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!

        while true {
            // define the interval [weekStart, weekStart + 1 week)
            let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
            // did you hoop in that week?
            let hasSession = sessions.contains {
                $0.date >= weekStart && $0.date < nextWeekStart
            }

            guard hasSession else {
                break   // first empty *completed* week stops the streak
            }

            streak += 1
            weekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: weekStart)!
        }

        return streak
    }

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
}
