//
//  ContentView.swift
//  Hoops
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var watchConnector = WatchConnector()
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Sessions()
            .onAppear {
                watchConnector.modelContext = context
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(HoopSession.preview)
}
