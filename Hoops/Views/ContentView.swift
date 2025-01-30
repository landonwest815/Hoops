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
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    @State private var selectedShotType: ShotType = .allShots
    @State private var isSheetPresented = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Sessions(selectedShotType: $selectedShotType)
                
                VStack {
                    Button(action: addRandomSession) {
                        HStack(spacing: 7.5) {
//                            Image(systemName: "basketball.fill")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 20, height: 20)
//                                .foregroundStyle(.orange)
//                                .fontWeight(.semibold)
                            
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
                    
                    Spacer()
                }
                .padding(.top, 62)
                .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    Picker("Shot Type", selection: $selectedShotType.animation(.bouncy)) {
//                        Text("All Shots (\(sessions.count))").tag(ShotType.allShots)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                            .font(.subheadline)
//                        ForEach(ShotType.allCases.filter { $0 != .allShots }, id: \.self) { type in
//                            let count = sessions.filter { $0.shotType == type }.count
//                            Text("\(type.rawValue.capitalized) (\(count))").tag(type as ShotType?)
//                                .frame(width: 50)
//                                .fontWeight(.semibold)
//                                .fontDesign(.rounded)
//                                .font(.subheadline)
//                        }
//                    }
//                    .pickerStyle(.menu)
//                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { isSheetPresented = true }) {
                        Image(systemName: "chart.bar.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22.5, height: 22.5)
                            .foregroundStyle(.orange)
                            .fontWeight(.semibold)
                    }
                }
                
            }
            .sheet(isPresented: $isSheetPresented) {
                Stats(shotType: $selectedShotType)
                    .presentationCornerRadius(50)
                    .presentationDetents([.fraction(0.965)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThickMaterial)
            }
        }
        .onAppear() {
            watchConnecter.modelContext = context
        }
        
    }
    
    private func deleteSessionsForSelectedShotType() {
        let sessionsToDelete: [HoopSession]
        
        if selectedShotType != .allShots {
            // Filter sessions by the selected shot type
            sessionsToDelete = sessions.filter { $0.shotType == selectedShotType }
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
            print("Deleted \(sessionsToDelete.count) session(s) for \(selectedShotType.rawValue.capitalized).")
        } catch {
            print("Failed to delete sessions: \(error.localizedDescription)")
        }
    }
    
    private func addRandomSession() {
        let shotTypeToAdd = selectedShotType

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
    
    // -- LAYUPS (3 examples) --
    let layups1 = HoopSession(
        date: Date(timeInterval: -86400 * 3, since: .now), // 3 days ago
        makes: 12,
        length: 180,
        shotType: .layups
    )
    container.mainContext.insert(layups1)
    
    let layups2 = HoopSession(
        date: Date(timeInterval: -86400 * 2, since: .now), // 2 days ago
        makes: 9,
        length: 220,
        shotType: .layups
    )
    container.mainContext.insert(layups2)
    
    let layups3 = HoopSession(
        date: Date(timeInterval: -86400, since: .now), // 1 day ago
        makes: 15,
        length: 240,
        shotType: .layups
    )
    container.mainContext.insert(layups3)
    
    // -- MIDRANGE (3 examples) --
    let midrange1 = HoopSession(
        date: Date(), // now
        makes: 5,
        length: 100,
        shotType: .midrange
    )
    container.mainContext.insert(midrange1)
    
    let midrange2 = HoopSession(
        date: Date(timeInterval: 86400, since: .now), // +1 day
        makes: 6,
        length: 130,
        shotType: .midrange
    )
    container.mainContext.insert(midrange2)
    
    let midrange3 = HoopSession(
        date: Date(timeInterval: 86400 * 2, since: .now), // +2 days
        makes: 4,
        length: 90,
        shotType: .midrange
    )
    container.mainContext.insert(midrange3)
    
    // -- FREE THROWS (3 examples) --
    let freeThrows1 = HoopSession(
        date: Date(timeInterval: -86400 * 2, since: .now),
        makes: 10,
        length: 120,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows1)
    
    let freeThrows2 = HoopSession(
        date: Date(timeInterval: -86400, since: .now),
        makes: 12,
        length: 90,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows2)
    
    let freeThrows3 = HoopSession(
        date: Date(timeInterval: 86400, since: .now),
        makes: 8,
        length: 110,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows3)
    
    // -- THREE POINTERS (3 examples) --
    let threePointers1 = HoopSession(
        date: Date(timeInterval: -86400, since: .now),
        makes: 5,
        length: 150,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers1)
    
    let threePointers2 = HoopSession(
        date: Date(), // now
        makes: 7,
        length: 180,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers2)
    
    let threePointers3 = HoopSession(
        date: Date(timeInterval: 86400, since: .now), // +1 day
        makes: 9,
        length: 200,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers3)
    
    // -- ALL SHOTS (3 examples) --
    let allShots1 = HoopSession(
        date: Date(timeInterval: -86400 * 3, since: .now),
        makes: 10,
        length: 210,
        shotType: .allShots
    )
    container.mainContext.insert(allShots1)
    
    let allShots2 = HoopSession(
        date: Date(), // now
        makes: 6,
        length: 95,
        shotType: .allShots
    )
    container.mainContext.insert(allShots2)
    
    let allShots3 = HoopSession(
        date: Date(timeInterval: 86400 * 3, since: .now), // +3 days
        makes: 11,
        length: 160,
        shotType: .allShots
    )
    container.mainContext.insert(allShots3)

    // Return your main view with the model container attached
    return ContentView()
        .modelContainer(container)
}
