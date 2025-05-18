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
                    .presentationDetents([.fraction(AppConstants.SheetHeights.current.onboarding)])
                    .sheetStyle()
                    .interactiveDismissDisabled()
                    .presentationDragIndicator(.hidden)
            }
            .preferredColorScheme(.dark)
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .modelContainer(HoopSession.preview)
                .previewDisplayName("iPhone Pro")
            
            ContentView()
                .modelContainer(HoopSession.preview)
                .previewDisplayName("iPhone Base")
            
            ContentView()
                .modelContainer(HoopSession.preview)
                .previewDisplayName("iPhone SE")
        }
        .preferredColorScheme(.dark)
    }
}
#endif
