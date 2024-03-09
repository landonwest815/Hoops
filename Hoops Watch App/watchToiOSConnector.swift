//
//  watchToiOSConnector.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/3/24.
//

import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            // Handle the error appropriately
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func sendSessionToiPhone(hoopSession: HoopSession) {
        // Prepare the data dictionary
        let data: [String: Any] = [
            "date": hoopSession.date,
            "makes": hoopSession.makes,
            "length": hoopSession.length,
            "shotType": hoopSession.shotType.rawValue
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
}
