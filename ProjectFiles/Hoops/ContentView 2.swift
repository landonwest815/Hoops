//
//  ContentView 2.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//


//
//  ContentView.swift
//  Hoops
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import SwiftData

/// The root view of the Hoops app.
/// It embeds the Sessions view and configures the watch connectivity by passing the data model context.
struct ContentView: View {
    // MARK: - Properties
    
    /// An instance of WatchConnector, used to communicate with the paired Apple Watch.
    @StateObject var watchConnecter = WatchConnector()
    /// The data model context from SwiftData for persistence.
    @Environment(\.modelContext) var context
    
    // MARK: - Body
    var body: some View {
        // Embed the Sessions view.
        Sessions()
            // When this view appears, assign the current model context to the watch connector.
            .onAppear {
                watchConnecter.modelContext = context
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(HoopSession.preview)
}
