//
//  HoopsApp.swift
//  Hoops
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import SwiftData

@main
struct HoopsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [HoopSession.self, UserSettings.self])
        }
    }
}
