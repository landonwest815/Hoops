//
//  HoopsTests.swift
//  HoopsTests
//
//  Created by Landon West on 4/10/25.
//

import XCTest
import Testing
import Foundation
import SwiftData
@testable import Hoops

// MARK: - Sample Business Logic Tests
struct HoopsTests {

    // Test the SessionsLogic.updateStats(for:) function.
    @Test func testUpdateStats() async throws {
        // Create two dummy sessions.
        let session1 = HoopSession(date: Date(), makes: 10, length: 60, shotType: .layups, sessionType: .freestyle)
        let session2 = HoopSession(date: Date(), makes: 20, length: 120, shotType: .layups, sessionType: .freestyle)
        
        // Expected: Count=2, total makes = 30, total time = 180 seconds.
        // Average makes per minute = (30 / 180) * 60 = 10
        let stats = SessionsLogic.updateStats(for: [session1, session2])
        #expect(stats.count == 2)
        #expect(stats.totalMakes == 30)
        #expect(stats.average == 10.0)
    }

    // Test the SessionsLogic.calculateAllTimeAverage(for:) function.
    @Test func testCalculateAllTimeAverage() async throws {
        let session1 = HoopSession(date: Date(), makes: 15, length: 90, shotType: .freeThrows, sessionType: .freestyle)
        let session2 = HoopSession(date: Date(), makes: 25, length: 150, shotType: .freeThrows, sessionType: .freestyle)
        // Total makes = 40, total time = 240 sec; average = (40/240)*60 = 10
        let avg = SessionsLogic.calculateAllTimeAverage(for: [session1, session2])
        #expect(avg == 10.0)
    }
    
    // Test the SessionsLogic.calculateStreak(from:) function.
    @Test func testCalculateStreak() async throws {
        let calendar = Calendar.current
        // Create sessions on three consecutive days.
        let today = Date()
        let sessionToday = HoopSession(date: today, makes: 10, length: 60, shotType: .midrange, sessionType: .freestyle)
        let sessionYesterday = HoopSession(date: calendar.date(byAdding: .day, value: -1, to: today)!, makes: 8, length: 60, shotType: .midrange, sessionType: .freestyle)
        let sessionDayBefore = HoopSession(date: calendar.date(byAdding: .day, value: -2, to: today)!, makes: 12, length: 60, shotType: .midrange, sessionType: .freestyle)
        
        // This should yield a streak of 3.
        let streak = SessionsLogic.calculateStreak(from: [sessionToday, sessionYesterday, sessionDayBefore])
        #expect(streak == 3)
        
        // Now, add an extra session that is not consecutive (skips one day).
        let sessionSkipped = HoopSession(date: calendar.date(byAdding: .day, value: -4, to: today)!, makes: 10, length: 60, shotType: .midrange, sessionType: .freestyle)
        let streakBroken = SessionsLogic.calculateStreak(from: [sessionToday, sessionYesterday, sessionSkipped])
        #expect(streakBroken == 2)  // Only the two most recent days are consecutive.
    }
    
    // Test the SessionsLogic.generateRandomSession(for:) function.
    @Test func testGenerateRandomSession() async throws {
        let selectedDate = Date()
        let randomSession = SessionsLogic.generateRandomSession(for: selectedDate)
        
        // Ensure the generated session uses the selected date's components.
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let sessionComponents = calendar.dateComponents([.year, .month, .day], from: randomSession.date)
        #expect(selectedComponents == sessionComponents)
        
        // Check that makes and length are within a plausible range.
        #expect(randomSession.makes >= 5)
        #expect(randomSession.length >= 60)
    }
    
    // Test the trophyLevel(for:thresholds:) helper.
    @Test func testTrophyLevel() async throws {
        // If the value is below the bronze threshold...
        var level = trophyLevel(for: 5, thresholds: (bronze: 10, silver: 25, gold: 50))
        #expect(level == .none)
        
        // At bronze threshold.
        level = trophyLevel(for: 10, thresholds: (bronze: 10, silver: 25, gold: 50))
        #expect(level == .bronze)
        
        // At silver threshold.
        level = trophyLevel(for: 30, thresholds: (bronze: 10, silver: 25, gold: 50))
        #expect(level == .silver)
        
        // At gold threshold.
        level = trophyLevel(for: 50, thresholds: (bronze: 10, silver: 25, gold: 50))
        #expect(level == .gold)
    }
    
    // Test the helper function getShotPoints(for:) from SessionThumbnail.swift.
    @Test func testGetShotPoints() async throws {
        // Expect "+2" for layups, midrange, and free throws.
        #expect(getShotPoints(for: .layups) == "+2")
        #expect(getShotPoints(for: .midrange) == "+2")
        #expect(getShotPoints(for: .freeThrows) == "+2")
        // Expect "+3" for threePointers and deep.
        #expect(getShotPoints(for: .threePointers) == "+3")
        #expect(getShotPoints(for: .deep) == "+3")
        // For allShots, based on your implementation, the helper returns a generic label.
        #expect(getShotPoints(for: .allShots) == "+")
    }
    
    // MARK: - UI Tests

//    /// Tests that the main Sessions view loads and expected UI elements are present.
//    @Test func testSessionsViewUI() async throws {
//        // Launch the application.
//        let app = await XCUIApplication()
//        await app.launch()
//
//        // Verify that a key UI element exists.
//        // For example, check that the navigation bar title "hoops." is present.
//        let title = await app.staticTexts["hoops."]
//        #expect(title.waitForExistence(timeout: 5))
//
//        // Check for the presence of a floating action button.
//        // (It can be helpful to set an accessibility identifier in your code for the FAB.)
//        // For example, assume that the FAB has an identifier "addSessionButton"
//        // Uncomment the following lines if you have set accessibility identifiers.
//        /*
//        let addButton = app.buttons["addSessionButton"]
//        #expect(addButton.exists)
//        addButton.tap()
//        */
//    }
//
//    /// Tests the week pager functionality by checking if swiping changes the selected date.
//    @Test func testWeekPagerUI() async throws {
//        let app = await XCUIApplication()
//        await app.launch()
//
//        // Assume that the WeekPagerView is present and displays day labels.
//        // Look for a known day label, e.g. if today is "15" then expect a text element with "15" exists.
//        // You might need to adjust this part based on your dynamic content.
//        let today = Date()
//        let dayComponent = Calendar.current.component(.day, from: today)
//        let dayLabel = await app.staticTexts["\(dayComponent)"]
//        #expect(dayLabel.waitForExistence(timeout: 5))
//
//        // Simulate a swipe to change the week page.
//        await app.swipeLeft()
//        // After swiping, the selected date should update. Depending on your implementation,
//        // check that the dayLabel changes or that a related UI element updates.
//        // This is just an example check.
//        let newDayLabel = await app.staticTexts["\(dayComponent - 7)"]
//        // Not all weeks will have the same day numbers so adjust the logic as needed.
//        await #expect(newDayLabel.exists || true)  // Add logic specific to your app.
//    }
}
