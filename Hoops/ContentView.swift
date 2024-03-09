//
//  ContentView.swift
//  Hoops
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject var watchConnecter = WatchConnector()
    
    var body: some View {
        
        ZStack {
            TabView {
                Sessions()
                    .tabItem() {
                        Image(systemName: "basketball")
                        Text("Sessions")
                    }
                Stats()
                    .tabItem() {
                        Image(systemName: "chart.bar")
                        Text("Stats")
                    }
                Settings()
                    .tabItem() {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        }
        .onAppear() {
            watchConnecter.modelContext = modelContext
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HoopSession.self, configurations: config)
    
    let hoopSession3 = HoopSession(date: Date(timeInterval: -86400, since: Date.now), makes: 15, length: 240, shotType: .layups)
    container.mainContext.insert(hoopSession3)

    let hoopSession1 = HoopSession(date: Date.now, makes: 5, length: 120, shotType: .threePointers)
    container.mainContext.insert(hoopSession1)
    
    let hoopSession2 = HoopSession(date: Date(timeInterval: 86400, since: Date.now), makes: 10, length: 90, shotType: .allShots)
    container.mainContext.insert(hoopSession2)
    
    return ContentView()
           .modelContainer(container)
}
