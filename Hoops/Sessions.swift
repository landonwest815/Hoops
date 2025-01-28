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
    
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    
    @State private var selectedShotType: ShotType? = nil
    
    @State private var isSheetPresented = false
    
    private var filteredSessions: [HoopSession] {
        if let shotType = selectedShotType {
            return sessions.filter { $0.shotType == shotType }
        } else {
            return sessions
        }
    }
    
    private var groupedSessions: [(key: Date, value: [HoopSession])] {
        Dictionary(grouping: filteredSessions) { $0.date.startOfDay }
            .sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // List of sessions
                List {
                    ForEach(groupedSessions, id: \.key) { day, daySessions in
                        Section(header: Text(day, style: .date)) {
                            ForEach(daySessions, id: \.self) { session in
                                SessionThumbnail(
                                    date: session.date,
                                    makes: session.makes,
                                    length: session.length,
                                    average: Double(session.makes) / (Double(session.length) / 60.0),
                                    shotType: session.shotType
                                )
                                .onLongPressGesture {
                                    context.delete(session)
                                }
                                .frame(height: 52.5)
                            }
                        }
                    }
                    .listSectionSpacing(15)
                }
                .listRowSpacing(8)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: addRandomSession) {
                        HStack(spacing: 7.5) {
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                                
                            Text("hoops.")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                        }
                        .onLongPressGesture {
                            deleteSessionsForSelectedShotType()
                        }
                    }
                }
                ToolbarItemGroup(placement: .automatic) {
                    // Dropdown menu for selecting shot type
                    Picker("Shot Type", selection: $selectedShotType) {
                        Text("All Shots (\(sessions.count))").tag(ShotType?.none)
                        ForEach(ShotType.allCases, id: \.self) { type in
                            let count = sessions.filter { $0.shotType == type }.count
                            Text("\(type.rawValue.capitalized) (\(count))").tag(type as ShotType?)
                                .frame(width: 50)
                        }
                    }
                    .pickerStyle(.menu)
                    //.padding(.horizontal)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { isSheetPresented = true }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(.orange)
                    }
                }
                
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            Stats()
                .presentationCornerRadius(50)
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func deleteSessionsForSelectedShotType() {
        let sessionsToDelete: [HoopSession]
        
        if let selectedType = selectedShotType {
            // Filter sessions by the selected shot type
            sessionsToDelete = sessions.filter { $0.shotType == selectedType }
        } else {
            // If "All Shots" is selected, delete all sessions
            sessionsToDelete = sessions
        }
        
        // Perform deletion
        withAnimation {
            for session in sessionsToDelete {
                context.delete(session)
            }
        }
        
        do {
            try context.save()
            print("Deleted \(sessionsToDelete.count) session(s) for \(selectedShotType?.rawValue.capitalized ?? "All Shots").")
        } catch {
            print("Failed to delete sessions: \(error.localizedDescription)")
        }
    }
    
    private func addRandomSession() {
        let shotTypeToAdd = selectedShotType ?? ShotType.allCases.randomElement()!

        let randomSession = HoopSession(
            date: .now,
            makes: Int.random(in: 5...40),
            length: Int.random(in: 60...600),
            shotType: shotTypeToAdd
        )
        withAnimation {
            context.insert(randomSession)
        }
        do {
            try context.save()
            print("New random session added!")
        } catch {
            print("Failed to save new session: \(error.localizedDescription)")
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
