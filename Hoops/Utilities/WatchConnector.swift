//
//  WatchConnector.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import Foundation
import WatchConnectivity
import SwiftData
import UserNotifications

/// A connector that manages the WatchConnectivity session between the iPhone and the Apple Watch,
/// handles incoming messages, and sends local notifications.
class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    /// The data context used for inserting new HoopSession objects. This must be set before expecting data persistence.
    var modelContext: ModelContext? = nil
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                // Optionally log whether permission was granted.
                print("Notification permission granted: \(granted)")
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // No custom behavior; may add logging if needed.
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate the session when it deactivates.
        session.activate()
    }
    
    /// Handles incoming messages from the paired device.
    /// Decodes message information, creates a new HoopSession, inserts it into the data store,
    /// and sends a local notification.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
        
        // Parse shotType and provide a default if parsing fails.
        let shotTypeRawValue = message["shotType"] as? String
        let shotType = ShotType(rawValue: shotTypeRawValue ?? "") ?? .allShots
        
        // Parse sessionType and provide a default if parsing fails.
        let sessionTypeRawValue = message["sessionType"] as? String
        let sessionType = SessionType(rawValue: sessionTypeRawValue ?? "") ?? .challenge
        
        // Ensure that the "length" key exists; otherwise, ignore the message.
        guard let length = message["length"] as? Int else {
            print("Warning: Missing 'length' in message; ignoring message.")
            return
        }

        // Create a new HoopSession using the received message data.
        let hoopSession = HoopSession(
            date: message["date"] as? Date ?? Date.now,
            makes: message["makes"] as? Int ?? 0,
            length: message["length"] as? Int ?? 0,
            shotType: shotType,
            sessionType: sessionType
        )
        
        // Insert the new session into the data context on the main thread.
        DispatchQueue.main.async {
            if let context = self.modelContext {
                context.insert(hoopSession)
            } else {
                print("Warning: modelContext is nil; cannot insert hoopSession.")
            }
        }

        // Send a local notification to inform the user.
        sendLocalNotification(shotType: shotType, sessionType: sessionType, length: length)
    }
    
    /// Schedules a local notification using the provided session details.
    /// - Parameters:
    ///   - shotType: The shot type of the session.
    ///   - sessionType: The session type.
    ///   - length: The duration of the session.
    private func sendLocalNotification(shotType: ShotType, sessionType: SessionType, length: Int) {
        let content = UNMutableNotificationContent()
        content.title = "New \(sessionType.rawValue) Session"
        content.body = "\(shotType.rawValue)  |  \(length / 60) min \(length % 60) sec"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Local notification scheduled successfully.")
            }
        }
    }
}

