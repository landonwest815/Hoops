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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContainer.mainContext)
                .environmentObject(watchConnector)
                .onAppear {
                    watchConnector.modelContext = modelContainer.mainContext
                }
        }
    }
}
