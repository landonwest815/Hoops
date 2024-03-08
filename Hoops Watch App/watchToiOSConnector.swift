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
        
    }
    
    func sendSessionToiPhone(hoopSession: HoopSession) {
        if session.isReachable {
            let data : [String: Any] = [
                "date": hoopSession.date,
                "makes": hoopSession.makes,
                "length": hoopSession.length
            ]
            
            session.sendMessage(data, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        } else {
            print("session is not reachable")
        }
    }
}
