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
    
    // Persisted flag — false until the user has seen (and dismissed) onboarding
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    // Local binding just to drive the sheet
    @State private var showOnboarding = false
    
    var body: some View {
        Sessions(showOnboarding: $showOnboarding)
            .onAppear {
                watchConnector.modelContext = context
                // if they’ve never seen it, flip on the sheet
                if !hasSeenOnboarding {
                    showOnboarding = true
                }
            }
            .sheet(
                isPresented: $showOnboarding,
                onDismiss: {
                    // once dismissed, mark it “seen” permanently
                    hasSeenOnboarding = true
                }
            ) {
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
