//
//  WatchConnector.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import WatchConnectivity
import SwiftData
import UserNotifications

/// Manages WatchConnectivity between iPhone and Apple Watch and posts a notification on new sessions.
class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    private let session: WCSession
    var modelContext: ModelContext?

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
              print("Notification permission error: \(error)")
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error)")
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let length = message["length"] as? Int else { return }

        let shotType = ShotType(rawValue: message["shotType"] as? String ?? "") ?? .allShots
        let sessionType = SessionType(rawValue: message["sessionType"] as? String ?? "") ?? .challenge

        let hoopSession = HoopSession(
            date: message["date"] as? Date ?? .now,
            makes: message["makes"] as? Int ?? 0,
            length: length,
            shotType: shotType,
            sessionType: sessionType
        )

        DispatchQueue.main.async {
            if let context = self.modelContext {
                context.insert(hoopSession)
            }
        }

        sendNotification(shotType: shotType, sessionType: sessionType, length: length)
    }

    private func sendNotification(shotType: ShotType, sessionType: SessionType, length: Int) {
        let content = UNMutableNotificationContent()
        content.title = "New \(sessionType.rawValue) Session"
        content.body = "\(shotType.rawValue) | \(length/60)m \(length%60)s"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling failed: \(error)")
            }
        }
    }
}
