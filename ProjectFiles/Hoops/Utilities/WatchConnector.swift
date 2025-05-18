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
    static let shared = WatchConnector()
    private let session = WCSession.default
    var modelContext: ModelContext?

    override init() {
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

    // Singleton that hands out notification titles in a shuffled order, per shot type,
    // and never repeats until every title has been used once.
    final class NotificationTitleProvider {
        static let shared = NotificationTitleProvider()

        private var queues: [ShotType: [String]] = [:]
        private let allTitles: [ShotType: [String]] = [
            .layups: [
                "Nothing but net down low! 🏀",
                "Smooth finishes! 💪",
                "Layup game on point! ⭐️",
                "At the rim like Wemby! 👽",
                "Owning the paint like Shaq! 💥"
            ],
            .freeThrows: [
                "Free throws locked in! 🎯",
                "Nailed those freebies! 🙌",
                "Perfect from the line! 🏅",
                "Mamba Mentality at the stripe! 🐍"
            ],
            .midrange: [
                "Midrange magic! ✨",
                "Sweet pull-up jumper! 🌟",
                "That midrange is money! 💰",
                "Mid-range magic, CP3 style! 🏀",
                "Dirk-style one-legged splash! 🇩🇪"
            ],
            .threePointers: [
                "Splash! 🌊",
                "Rainmaker from deep! ☔️",
                "Triple threat success! 🎯",
                "Steph Curry with the shot! 🏆",
                "Splash Brother energy! 💦"
            ],
            .deep: [
                "Deep bomb detonated! 💣",
                "From way downtown! 🏙️",
                "Ice cold from deep! ❄️",
                "Lillard’s range unlocked! 🔥",
                "Luka Magic deep dagger! 🔪"
            ],
            .allShots: [
                "Great job on your session! 🏀",
                "You crushed it! 🔥",
                "Hoops session complete! ⛹️‍♂️",
                "Keep that momentum! 🙌",
                "Time to celebrate those makes! 🎉",
            ]
        ]

        private init() {
          resetAllQueues()
        }

        private func resetAllQueues() {
          queues = allTitles.mapValues { titles in titles.shuffled() }
        }

        /// Returns the next title for a given shot type, reshuffling when exhausted.
        func next(for shotType: ShotType) -> String {
          // if queue empty (or not yet created), refill & shuffle
          if queues[shotType]?.isEmpty ?? true {
            queues[shotType] = allTitles[shotType]!.shuffled()
          }
          // pop the first off
          return queues[shotType]!.removeFirst()
        }
    }

    private func sendNotification(shotType: ShotType, sessionType: SessionType, length: Int) {
        let content = UNMutableNotificationContent()
        content.title = NotificationTitleProvider.shared.next(for: shotType)
        content.body = "\(shotType.rawValue) \(sessionType.rawValue) completed"
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
