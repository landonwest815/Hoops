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
    ContentView()
}
