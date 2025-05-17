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
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false

    var body: some View {
        Sessions(showOnboarding: $showOnboarding)
            .onAppear {
                watchConnector.modelContext = context
                if !hasSeenOnboarding {
                    showOnboarding = true
                }
            }
            .sheet(
                isPresented: $showOnboarding,
                onDismiss: { hasSeenOnboarding = true }
            ) {
                OnboardingView(isPresented: $showOnboarding)
                    .presentationDetents([.fraction(0.65)])
                    .sheetStyle()
                    .interactiveDismissDisabled()
                    .presentationDragIndicator(.hidden)
            }
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(HoopSession.preview)
}
