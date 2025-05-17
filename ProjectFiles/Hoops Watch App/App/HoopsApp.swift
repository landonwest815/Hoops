//
//  HoopsApp.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import SwiftData
import HealthKit

@main
struct Hoops_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [HoopSession.self])
        }
    }
}
