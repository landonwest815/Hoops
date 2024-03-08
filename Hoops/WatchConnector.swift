//
//  WatchConnector.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import Foundation
import WatchConnectivity
import SwiftData

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    var modelContext: ModelContext? = nil
    
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
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Necessary to reactivate the session after it has been deactivated.
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        var hoopSession = HoopSession(
            date: message["date"] as? Date ?? Date.now,
            makes: message["makes"] as? Int ?? 0,
            length: message["length"] as? Int ?? 0)
        
        DispatchQueue.main.async {
            self.modelContext?.insert(hoopSession)
        }
    }
}
