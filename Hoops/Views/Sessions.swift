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
    @State var selectedShotType: ShotType = .allShots
    @State private var isSheetPresented = false
    @State var selectedDate: Date = .now
    
    @State private var sessionCount: Int = 0
    @State private var totalMakes: Int = 0
    @State private var averageMakesPerMinute: Double = 0
    
    @State var streak = 0
    
    private var filteredSessions: [HoopSession] {
//        if selectedShotType != .allShots {
//            return sessions.filter { $0.shotType == selectedShotType }
//        } else {
            return sessions
        //}
    }
    
    private var groupedSessions: [(key: Date, value: [HoopSession])] {
        Dictionary(grouping: filteredSessions) { $0.date.startOfDay }
            .sorted { $0.key > $1.key }
    }
    
    private var selectedDaySessions: [HoopSession] {
        groupedSessions.first(where: { $0.key == selectedDate.startOfDay })?.value ?? []
    }

    var body: some View {
        
        NavigationView {
                
            ZStack(alignment: .top) {
                
                VStack(alignment: .trailing, spacing: 0) {
                    
                    ZStack(alignment: .top) {
                        
                        // List of sessions
                        ScrollView {
                            
                            LazyVStack(spacing: 10) {
                                
                                HStack(spacing: 15) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "basketball.fill")
                                                .foregroundStyle(.orange)
                                                .fontWeight(.semibold)
                                            
                                            Text("\(sessionCount)")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .contentTransition(.numericText())
                                        }
                                        
                                        Text("Sessions")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Divider()
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "scope")
                                                .foregroundStyle(.red)
                                                .fontWeight(.semibold)
                                            
                                            Text("\(totalMakes)")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .contentTransition(.numericText())
                                        }
                                        
                                        Text("Total Makes")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Divider()
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .foregroundStyle(.blue)
                                                .fontWeight(.semibold)
                                            
                                            HStack(spacing: 5) {
                                                Text("\(averageMakesPerMinute, specifier: "%.2f")")
                                                    .font(.title3)
                                                    .fontDesign(.rounded)
                                                    .fontWeight(.semibold)
                                                    .contentTransition(.numericText())
                                                
                                                Text("/min")
                                                    .font(.subheadline)
                                                    .fontDesign(.rounded)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        Text("Average Makes")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                                .padding(.top, 15)
                                
                                // Date label and buttons
                                HStack {
                                    Text(selectedDate, style: .date)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .contentTransition(.numericText())
                                    
                                    Spacer()
                                    
                                    Button {
                                        
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .foregroundStyle(.clear)
                                                .frame(width: 25, height: 25)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                                            Image(systemName: "arrow.up.arrow.down")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 15)
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                    
                                    Button {
                                        
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .foregroundStyle(.clear)
                                                .frame(width: 25, height: 25)
                                                .background(.ultraThickMaterial)
                                                .clipShape(Circle())
                                            Image(systemName: "line.3.horizontal.decrease")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 15)
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                    
                                }
                                .padding(.top, 10)
                                .padding(.horizontal)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                                
                                // Show message if there are no sessions
                                if selectedDaySessions.isEmpty {
                                    VStack {
                                        Text("Go put some shots up!")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .foregroundStyle(.secondary)
                                            .padding(.top, 20)
                                    }
                                } else {
                                    // Filtered session list
                                    ForEach(selectedDaySessions, id: \.self) { session in
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
                                        .frame(height: 75)
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0)
                                                .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                                .blur(radius: phase.isIdentity ? 0 : 10)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .background(.black)
                .padding(.top, 90)
                
                VStack(spacing: 0) {
                    WeekView(selectedDate: $selectedDate)
                        .padding(.top, 5)
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(.gray.opacity(0.66))

                }
                .background(.ultraThinMaterial)
                
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
                            
                            if streak > 1 {
                                ZStack {
                                    Image(systemName: "flame.fill")
                                        .resizable()
                                        .frame(width: 21, height: 23)
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 11, height: 11)
                                        .offset(y: 4)
                                    Text("\(streak)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.white)
                                        .offset(x: -0.25, y: 1.75)
                                        .shadow(radius: 5)
                                        .contentTransition(.numericText())
                                }
                                .foregroundStyle(.red)
                            }
                            
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
                    Button {
                        withAnimation {
                            addRandomSession()
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                    .foregroundStyle(.secondary)
                }
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
            .onAppear {
                updateStats()
                calculateStreak()
            }
            .onChange(of: sessions) {
                withAnimation {
                    updateStats()
                    calculateStreak()
                }
            }
            .onChange(of: selectedDate) {
                print("test")
                withAnimation {
                    updateStats()
                    calculateStreak()

                }
            }
        }
    }
    
    private func updateStats() {
        let selectedDaySessions = sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
        sessionCount = selectedDaySessions.count
        totalMakes = selectedDaySessions.reduce(0) { $0 + $1.makes }
        
        let totalTime = selectedDaySessions.reduce(0) { $0 + $1.length }
        averageMakesPerMinute = totalTime > 0 ? Double(totalMakes) / Double(totalTime) * 60 : 0
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
        let currentTime = Date() // Capture the current time

        let calendar = Calendar.current
        var selectedDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: currentTime),
            minute: calendar.component(.minute, from: currentTime),
            second: calendar.component(.second, from: currentTime),
            of: selectedDate
        ) ?? selectedDate  // Fallback in case of failure

        // Ensure uniqueness by adding a slight millisecond offset
        selectedDateTime = selectedDateTime.addingTimeInterval(Double.random(in: 0.001...0.999))

        let randomSession = HoopSession(
            date: selectedDateTime,  // ✅ Now has a unique timestamp
            makes: Int.random(in: 5...40),
            length: Int.random(in: 60...600),
            shotType: shotTypeToAdd
        )

        withAnimation {
            context.insert(randomSession)
        }
        
        do {
            try context.save()
            print("New random session added at \(selectedDateTime)!")
        } catch {
            print("Failed to save new session: \(error.localizedDescription)")
        }
    }
    
    private func calculateStreak() {
        let calendar = Calendar.current
        let uniqueDays = Set(sessions.map { $0.date.startOfDay }) // Extract unique session days
        let sortedDays = uniqueDays.sorted(by: >) // Sort days from latest to earliest

        guard let latestDay = sortedDays.first else {
            streak = 0
            return
        }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now.startOfDay)!

        // Ensure yesterday had a session
        guard uniqueDays.contains(yesterday) else {
            withAnimation {
                streak = 0
            }
            return
        }

        var currentStreak = 1
        var previousDay = latestDay

        for day in sortedDays.dropFirst() {
            if calendar.date(byAdding: .day, value: -1, to: previousDay) == day {
                currentStreak += 1
                previousDay = day
            } else {
                break // Streak is broken
            }
        }

        withAnimation {
            streak = currentStreak
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

    // Return your main view with the model container attached
    return ContentView()
        .modelContainer(container)
}
