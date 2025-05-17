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
    private let session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func sendSessionToiPhone(hoopSession: HoopSession) {
        let data: [String: Any] = [
            "date": hoopSession.date,
            "makes": hoopSession.makes,
            "length": hoopSession.length,
            "shotType": hoopSession.shotType.rawValue,
            "sessionType": hoopSession.sessionType.rawValue
        ]

        if session.isReachable {
            session.sendMessage(data, replyHandler: nil) { error in
                print("sendMessage error: \(error.localizedDescription)")
            }
        } else {
            session.transferUserInfo(data)
        }
    }

    private func handleIncomingData(_ data: [String: Any]) {
        guard
            let shotType = data["shotType"] as? String,
            let sessionType = data["sessionType"] as? String,
            let length = data["length"] as? Int
        else { return }

        let content = UNMutableNotificationContent()
        content.title = "New \(sessionType) Session"
        content.body = "\(shotType)  |  \(length / 60) min \(length % 60) sec"
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

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) { }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { self.handleIncomingData(message) }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async { self.handleIncomingData(message) }
        replyHandler([:])
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        DispatchQueue.main.async { self.handleIncomingData(userInfo) }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.handleIncomingData(applicationContext) }
    }
}
