//
//  Sessions.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData

struct Sessions: View {
    
    @Environment(\.modelContext) var context
    
    @Query var sessions: [HoopSession]
    
    var body: some View {
        
        NavigationStack {
            
            // MARK: - List of Wants
                Form {
                    ForEach(sessions, id: \.self) { session in
                        // If a want is tapped, bring up its information using WantView
                        Section {
                            
                            SessionThumbnail(date: session.date, makes: session.makes, average: Double(session.makes) / (Double(session.length) / 60.0))
                                .onLongPressGesture {
                                    context.delete(session)
                                }

                        }
                    }
                    .listSectionSpacing(15)
                    .listRowSeparator(.hidden)
                }
                .toolbar() {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Image(systemName: "basketball.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .navigationTitle("Sessions")
                //.onDelete(perform: delete)
            }
        
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HoopSession.self, configurations: config)
    let hoopSession = HoopSession(date: Date.now, makes: 5, length: 120)
    container.mainContext.insert(hoopSession)

    return Sessions()
           .modelContainer(container)
}
