//
//  ContentView.swift
//  Hoops
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var watchConnecter = WatchConnector()
    @Environment(\.modelContext) var context
    @State var selectedTab: Int = 0
    
    var body: some View {
        
//        TabView(selection: $selectedTab) {
//            Sessions()
//                .tag(0)
//                .tabItem {
//                    Label("Home", systemImage: "basketball.fill")
//                }
//            Settings()
//                .tag(1)
//                .tabItem {
//                    Label("Home", systemImage: "chart.line.uptrend.xyaxis")
//                }
//            
//        }
        Sessions()
        .onAppear() {
            watchConnecter.modelContext = context
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(HoopSession.preview)
}
