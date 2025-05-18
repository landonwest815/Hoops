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
    let modelContainer = try! ModelContainer(for: HoopSession.self)
    @StateObject private var watchConnector = WatchConnector()
    @Environment(\.modelContext) private var context
    
    init() {
        // Make sure that if the key doesn't exist yet, it gets seeded at 10 am
        UserDefaults.standard.register(defaults: [
            "streakReminderSeconds": 10 * 3600
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContainer.mainContext)
                .environmentObject(watchConnector)
                .onAppear {
                    watchConnector.modelContext = modelContainer.mainContext
                    StreakReminderScheduler.updateReminder(in: context)
                }
        }
    }
}
