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
    
    var body: some View {
        
        ZStack {
            Sessions()
        }
        .onAppear() {
            watchConnecter.modelContext = context
        }
        
    }
    
}

#Preview {
    ContentView()
}
