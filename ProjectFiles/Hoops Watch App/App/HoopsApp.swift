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
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            ContentView(path: $path)
                .modelContainer(for: [HoopSession.self])
                .onOpenURL { url in
                    guard url.scheme == "hoops",
                          url.host   == "modeSelection"
                    else { return }

                    // 1) clear out any previous navigation
                    path = NavigationPath()

                    // 2) push modeSelection as the only destination
                    path.append(AppRoute.modeSelection)
                }
        }
    }
}
