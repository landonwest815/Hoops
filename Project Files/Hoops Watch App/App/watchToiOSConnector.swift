//
//  watchToiOSConnector.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/3/24.
//

import Foundation
import WatchConnectivity
import UserNotifications

class WatchToiOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            // Handle the error appropriately
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.handleIncomingData(message)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        DispatchQueue.main.async {
            self.handleIncomingData(userInfo)
        }
    }
    
    func sendSessionToiPhone(hoopSession: HoopSession) {
        // Prepare the data dictionary
        let data: [String: Any] = [
            "date": hoopSession.date,
            "makes": hoopSession.makes,
            "length": hoopSession.length,
            "shotType": hoopSession.shotType.rawValue,
            "sessionType": hoopSession.sessionType.rawValue
        ]

        // Check if the session is reachable and prefer sendMessage for instant transfer if possible
        if session.isReachable {
            session.sendMessage(data, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        } else {
            // Use transferUserInfo for background transfer when session is not reachable
            session.transferUserInfo(data)
        }
    }
    
    private func handleIncomingData(_ data: [String: Any]) {
        guard let shotType = data["shotType"] as? String else { return }
        guard let sessionType = data["sessionType"] as? String else { return }
        guard let length = data["length"] as? Int else { return }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "New \(sessionType) Session"
        notificationContent.body = "\(shotType)  |  \(length / 60) min \(length % 60) sec"
        notificationContent.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: –– WCSessionDelegate stubs to silence console spam
extension WatchToiOSConnector {
    // called when you transferApplicationContext(...)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handleIncomingData(applicationContext)
        }
    }

    // called when reachability changes
    func sessionReachabilityDidChange(_ session: WCSession) {
        // no-op
    }

    // if you ever use sendMessage(_:replyHandler:)
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            self.handleIncomingData(message)
        }
        replyHandler([:])  // acknowledge receipt
    }
}
