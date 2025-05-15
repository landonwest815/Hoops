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
    @State private var showOnboarding = true
    
    var body: some View {
        Sessions()
            .onAppear {
                watchConnector.modelContext = context
            }
            .sheet(isPresented: $showOnboarding) {
                 OnboardingView(isPresented: $showOnboarding)
                    .presentationDetents([.fraction(0.65)])
                    .sheetStyle()
                    .interactiveDismissDisabled()
                    .presentationDragIndicator(.hidden)
             }
    }
}

#Preview {
    ContentView()
        .modelContainer(HoopSession.preview)
}
