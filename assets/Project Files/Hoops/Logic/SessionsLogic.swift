//
//  SessionsLogic.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import SwiftUI
import SwiftData

// MARK: - Business Logic (Separated from the View)
// This struct encapsulates helper functions for processing session-related data.
// It calculates statistics, generates random sessions, and determines various performance metrics.
struct SessionsLogic {
    
    /// Computes statistics for the given sessions.
    /// Returns a tuple with the session count, total makes, and average makes per minute.
    /// - Parameter sessions: An array of HoopSession objects.
    /// - Returns: A tuple containing:
    ///   - count: Total number of sessions.
    ///   - totalMakes: Sum of all makes from the sessions.
    ///   - average: Average makes per minute (computed over the total session length).
    static func updateStats(for sessions: [HoopSession]) -> (count: Int, totalMakes: Int, average: Double) {
        let count = sessions.count
        // Summing up all successful shots (makes) from each session.
        let totalMakes = sessions.reduce(0) { $0 + $1.makes }
        // Summing up all session durations.
        let totalTime = sessions.reduce(0) { $0 + $1.length }
        // Calculate average makes per minute (scales by 60 since length is assumed in seconds).
        let average = totalTime > 0 ? Double(totalMakes) / Double(totalTime) * 60 : 0
        return (count, totalMakes, average)
    }
    
    /// Calculates the all-time average makes per minute from all sessions.
    /// - Parameter sessions: An array of HoopSession objects.
    /// - Returns: A Double value representing the overall average makes per minute.
    static func calculateAllTimeAverage(for sessions: [HoopSession]) -> Double {
        let totalMakes = sessions.reduce(0) { $0 + $1.makes }
        let totalTime = sessions.reduce(0) { $0 + $1.length }
        return totalTime > 0 ? Double(totalMakes) / Double(totalTime) * 60 : 0
    }
    
    /// Calculates the current streak based on consecutive days where sessions occurred.
    /// - Parameter sessions: An array of HoopSession objects.
    /// - Returns: An integer representing the number of consecutive days with sessions.
    static func calculateStreak(from sessions: [HoopSession]) -> Int {
        let calendar = Calendar.current
        // Extract unique days (by startOfDay) that contain sessions.
        let uniqueDays = Set(sessions.map { $0.date.startOfDay })
        // Sort the days in descending order (newest day first).
        let sortedDays = uniqueDays.sorted(by: >)
        // If there are no sessions, return 0.
        guard let latestDay = sortedDays.first else { return 0 }
        // Compute what "yesterday" would be from today.
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date().startOfDay)!
        // If there is no session yesterday, then there's no streak.
        guard uniqueDays.contains(yesterday) else { return 0 }
        
        var currentStreak = 1
        var previousDay = latestDay
        // Loop through sorted days (skipping the latest) to count consecutive days.
        for day in sortedDays.dropFirst() {
            if calendar.date(byAdding: .day, value: -1, to: previousDay) == day {
                currentStreak += 1
                previousDay = day
            } else {
                break // Streak is broken if days are not consecutive.
            }
        }
        return currentStreak
    }
    
    /// Generates a random HoopSession for the provided date.
    /// - Parameter selectedDate: The date for which the session is generated.
    /// - Returns: A randomly generated HoopSession instance with random makes, length, and shotType.
    static func generateRandomSession(for selectedDate: Date) -> HoopSession {
        // Randomly select a shot type from available options.
        let shotTypeToAdd = ShotType.allCases.randomElement() ?? .allShots
        let currentTime = Date()
        let calendar = Calendar.current
        // Construct a date that preserves the time components from the current time for the selected date.
        var selectedDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: currentTime),
            minute: calendar.component(.minute, from: currentTime),
            second: calendar.component(.second, from: currentTime),
            of: selectedDate
        ) ?? selectedDate
        
        // Add a small random offset (in seconds) to avoid duplicate timestamps.
        selectedDateTime = selectedDateTime.addingTimeInterval(Double.random(in: 0.001...0.999))
        
        // Create and return a new HoopSession with random values for makes and length.
        return HoopSession(
            date: selectedDateTime,
            makes: Int.random(in: 5...40),
            length: Int.random(in: 60...600),
            shotType: shotTypeToAdd,
            sessionType: SessionType.allCases.randomElement() ?? .freestyle
        )
    }
    
    /// Calculates the total number of makes for all sessions.
    /// - Parameter sessions: An array of HoopSession objects.
    /// - Returns: The sum of makes from all sessions.
    static func calculateTotalMakes(for sessions: [HoopSession]) -> Int {
        return sessions.reduce(0) { $0 + $1.makes }
    }
    
    /// Calculates the number of unique days on which sessions occurred.
    /// - Parameter sessions: An array of HoopSession objects.
    /// - Returns: The count of distinct days based on session dates.
    static func calculateDaysHooped(for sessions: [HoopSession]) -> Int {
        let uniqueDays = Set(sessions.map { $0.date.startOfDay })
        return uniqueDays.count
    }
}
