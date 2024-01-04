//
//  watchToiOSConnector.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/3/24.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sendSessionToiPhone() {
        
    }
}
