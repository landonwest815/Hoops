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

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
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
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
        
        let shotTypeRawValue = message["shotType"] as? String
        let shotType = ShotType(rawValue: shotTypeRawValue ?? "") ?? .allShots

        let hoopSession = HoopSession(
            date: message["date"] as? Date ?? Date.now,
            makes: message["makes"] as? Int ?? 0,
            length: message["length"] as? Int ?? 0,
            shotType: shotType
        )
        
        DispatchQueue.main.async {
            self.modelContext?.insert(hoopSession)
        }

        // Send a notification
        sendLocalNotification(for: shotType)
    }
    
    private func sendLocalNotification(for shotType: ShotType) {
        let content = UNMutableNotificationContent()
        content.title = "New Basketball Session!"
        content.body = "New \(shotType.rawValue) session from Watch!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}

