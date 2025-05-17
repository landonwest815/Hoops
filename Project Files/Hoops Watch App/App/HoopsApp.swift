//
//  HoopsApp.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import SwiftData

@main
struct Hoops_Watch_AppApp: App {

    private let hkAuthorizer = HealthKitAuthorizer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [HoopSession.self])
                .onAppear {
                  // fire the HealthKit permission prompt immediately
                  hkAuthorizer.requestAuthorization()
                }
        }
    }
}



import HealthKit

final class HealthKitAuthorizer {
  private let healthStore = HKHealthStore()

  /// Call this once at launch to fire the permissions dialog up-front.
  func requestAuthorization() {
    guard HKHealthStore.isHealthDataAvailable() else { return }
    let typesToShare: Set = [ HKObjectType.workoutType() ]
    let typesToRead:  Set = [ HKObjectType.workoutType() ]
    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
      if let err = error {
        print("HealthKit auth error:", err.localizedDescription)
      }
    }
  }
}
