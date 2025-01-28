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
//            TabView {
//                Sessions()
//                    .tabItem() { 
//                        Image(systemName: "basketball")
//                        Text("Sessions")
//                    }
//                Stats()
//                    .tabItem() {
//                        Image(systemName: "chart.bar")
//                        Text("Stats")
//                    }
////                Settings()
////                    .tabItem() {
////                        Image(systemName: "gear")
////                        Text("Settings")
////                    }
//            }
            Sessions()
        }
        .onAppear() {
            watchConnecter.modelContext = modelContext
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HoopSession.self, configurations: config)
    
    // -- LAYUPS (3 examples) --
    let layups1 = HoopSession(
        date: Date(timeInterval: -86400 * 3, since: .now), // 3 days ago
        makes: 12,
        length: 180,
        shotType: .layups
    )
    container.mainContext.insert(layups1)
    
    let layups2 = HoopSession(
        date: Date(timeInterval: -86400 * 2, since: .now), // 2 days ago
        makes: 9,
        length: 220,
        shotType: .layups
    )
    container.mainContext.insert(layups2)
    
    let layups3 = HoopSession(
        date: Date(timeInterval: -86400, since: .now), // 1 day ago
        makes: 15,
        length: 240,
        shotType: .layups
    )
    container.mainContext.insert(layups3)
    
    // -- MIDRANGE (3 examples) --
    let midrange1 = HoopSession(
        date: Date(), // now
        makes: 5,
        length: 100,
        shotType: .midrange
    )
    container.mainContext.insert(midrange1)
    
    let midrange2 = HoopSession(
        date: Date(timeInterval: 86400, since: .now), // +1 day
        makes: 6,
        length: 130,
        shotType: .midrange
    )
    container.mainContext.insert(midrange2)
    
    let midrange3 = HoopSession(
        date: Date(timeInterval: 86400 * 2, since: .now), // +2 days
        makes: 4,
        length: 90,
        shotType: .midrange
    )
    container.mainContext.insert(midrange3)
    
    // -- FREE THROWS (3 examples) --
    let freeThrows1 = HoopSession(
        date: Date(timeInterval: -86400 * 2, since: .now),
        makes: 10,
        length: 120,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows1)
    
    let freeThrows2 = HoopSession(
        date: Date(timeInterval: -86400, since: .now),
        makes: 12,
        length: 90,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows2)
    
    let freeThrows3 = HoopSession(
        date: Date(timeInterval: 86400, since: .now),
        makes: 8,
        length: 110,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows3)
    
    // -- THREE POINTERS (3 examples) --
    let threePointers1 = HoopSession(
        date: Date(timeInterval: -86400, since: .now),
        makes: 5,
        length: 150,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers1)
    
    let threePointers2 = HoopSession(
        date: Date(), // now
        makes: 7,
        length: 180,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers2)
    
    let threePointers3 = HoopSession(
        date: Date(timeInterval: 86400, since: .now), // +1 day
        makes: 9,
        length: 200,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers3)
    
    // -- ALL SHOTS (3 examples) --
    let allShots1 = HoopSession(
        date: Date(timeInterval: -86400 * 3, since: .now),
        makes: 10,
        length: 210,
        shotType: .allShots
    )
    container.mainContext.insert(allShots1)
    
    let allShots2 = HoopSession(
        date: Date(), // now
        makes: 6,
        length: 95,
        shotType: .allShots
    )
    container.mainContext.insert(allShots2)
    
    let allShots3 = HoopSession(
        date: Date(timeInterval: 86400 * 3, since: .now), // +3 days
        makes: 11,
        length: 160,
        shotType: .allShots
    )
    container.mainContext.insert(allShots3)

    // Return your main view with the model container attached
    return ContentView()
        .modelContainer(container)
}
