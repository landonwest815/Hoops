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
    
    @Query(sort: \HoopSession.date) var sessions: [HoopSession]
    
    var groupedSessions: [(key: Date, value: [HoopSession])] {
        let grouped = Dictionary(grouping: sessions) { $0.date.startOfDay }
        let sortedGrouped = grouped.sorted { $0.key < $1.key }
        return sortedGrouped
    }
    
    var body: some View {
        
        NavigationStack {
            
            // MARK: - List of Wants
            Form {
                ForEach(groupedSessions, id: \.key) { day, daySessions in
                    Section(header: Text(day, style: .date)) {
                        ForEach(daySessions, id: \.self) { session in
                            SessionThumbnail(date: session.date, makes: session.makes, length: session.length, average: Double(session.makes) / (Double(session.length) / 60.0), shotType: session.shotType)
                                .onLongPressGesture {
                                    context.delete(session)
                                }
                                .frame(height: 52.5)
                        }
                    }
                }
                .listSectionSpacing(15)
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
    let hoopSession = HoopSession(date: Date.now, makes: 5, length: 120, shotType: .threePointers)
    container.mainContext.insert(hoopSession)

    return Sessions()
           .modelContainer(container)
}
