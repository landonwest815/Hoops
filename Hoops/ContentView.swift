//
//  ContentView.swift
//  Hoops
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
}
