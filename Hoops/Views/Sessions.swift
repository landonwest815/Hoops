//
//  Sessions.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData

enum GraphType: String, Codable, CaseIterable {
    case sessions = "Sessions"
    case makes = "Shot Makes"
    case average = "Average/Min"
    case none = "N/A"
}

struct Sessions: View {
    @Environment(\.modelContext) var context
    @Query(sort: \HoopSession.date, order: .reverse, animation: .default) var sessions: [HoopSession]
    @State var selectedShotType: ShotType = .allShots
    @State private var isSheetPresented = false
    @State var selectedDate: Date = .now
    
    @State private var sessionCount: Int = 0
    @State private var totalMakes: Int = 0
    @State private var averageMakesPerMinute: Double = 0
    
    @State var selectedGraph: GraphType = .none
    
    @State var streak = 0
    
    @State var isProfileShown = false
    
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
                                
            VStack(spacing: 0) {
                
                WeekView(selectedDate: $selectedDate)
                    .padding(.top, 5)
                
                HStack(spacing: 10) {
                    
                    Button {
                        withAnimation {
                            if selectedGraph != .sessions {
                                isSheetPresented = true
                                selectedGraph = .sessions
                            } else {
                                selectedGraph = .none
                                isSheetPresented = false
                            }
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "basketball.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 16)
                                    .foregroundStyle(.orange)
                                    .fontWeight(.semibold)
                                
                                
                                Text("\(sessionCount)")
                                    .font(.title3)
                                    .fontDesign(.rounded)
                                    .fontWeight(.semibold)
                                    .contentTransition(.numericText())
                                    .foregroundStyle(.white)
                            }
                            
                            Text("Sessions")
                                .font(.caption)
                                .fontWeight(.regular)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 90)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            selectedGraph == .sessions ?
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.66), lineWidth: 2)
                            : nil
                        )
                    }
                        
                    Button {
                        withAnimation {
                            if selectedGraph != .makes {
                                isSheetPresented = true
                                selectedGraph = .makes
                            } else {
                                selectedGraph = .none
                                isSheetPresented = false
                            }
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "scope")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 16)
                                    .foregroundStyle(.red)
                                    .fontWeight(.semibold)
                                
                                Text("\(totalMakes)")
                                    .font(.title3)
                                    .fontDesign(.rounded)
                                    .fontWeight(.semibold)
                                    .contentTransition(.numericText())
                                    .foregroundStyle(.white)
                            }
                            
                            Text("Total Makes")
                                .font(.caption)
                                .fontWeight(.regular)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 105)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            selectedGraph == .makes ?
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.66), lineWidth: 2.5)
                            : nil
                        )
                    }
                                            
                    Button {
                        withAnimation {
                            if selectedGraph != .average {
                                isSheetPresented = true
                                selectedGraph = .average
                            } else {
                                selectedGraph = .none
                                isSheetPresented = false
                            }
                        }
                    } label: {
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
                                        .foregroundStyle(.white)
                                    
                                    Text("/min")
                                        .font(.caption)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.gray)
                                        .offset(y: 1)
                                }
                            }
                            
                            Text("Average Makes")
                                .font(.caption)
                                .fontWeight(.regular)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            selectedGraph == .average ?
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.66), lineWidth: 2.5)
                            : nil
                        )
                    }
                    
                }
                .frame(height: 50)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                
                // Date label and buttons
                HStack {
                    Text(selectedDate, style: .date)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.clear)
                                .frame(width: 30, height: 30)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                            Image(systemName: "arrow.up.arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 17.5)
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.clear)
                                .frame(width: 30, height: 30)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                            Image(systemName: "line.3.horizontal.decrease")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 17.5)
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                        }
                    }
                    
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                
                ZStack(alignment: .bottomTrailing) {
                    
                    // List of sessions
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            
                            // Show message if there are no sessions
                            if selectedDaySessions.isEmpty {
                                VStack {
                                    Text(selectedDate.startOfDay == .now.startOfDay ? "Go shoot some hoops!" : "No sessions for today!")
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
                    }
                    
                    Button {
                        withAnimation {
                            addRandomSession()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                //.stroke(Color.orange.opacity(0.75), lineWidth: 1.5)
                                .fill(.ultraThinMaterial)
                                .frame(width: 66)
                            
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .foregroundStyle(.orange)
                            
                        }
                        .padding()
                        .padding(.horizontal)
                    }
                }
            }
            .background(.ultraThinMaterial)
            .navigationBarTitleDisplayMode(.inline)
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
                
                ToolbarItemGroup(placement: .principal) {
                    
                    Button {
                        isProfileShown = true
                    } label: {
                        HStack(spacing: 7.5) {
                            
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
                                .symbolEffect(.bounce, value: streak)
                                .shadow(color: .red.opacity(0.25), radius: 5)
                                .shadow(color: .red.opacity(0.125), radius: 12.5)
                                .shadow(color: .red.opacity(0.05), radius: 20)
                                
//                                if !hasSessionForToday() {
//                                    ZStack {
//                                        Image(systemName: "hourglass")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 13)
//                                            .foregroundStyle(.gray)
//                                    }
//                                }

                            }
                            
                        }
                    }
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
            .sheet(isPresented: $isSheetPresented, onDismiss: {
                withAnimation {
                    selectedGraph = .none
                }
            }) {
                Stats(shotType: $selectedShotType, selectedGraph: $selectedGraph)
                    .presentationCornerRadius(32)
                    .presentationDetents([.fraction(0.6875)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThickMaterial)
                    .presentationBackgroundInteraction(.enabled)
            }
            .sheet(isPresented: $isProfileShown, onDismiss: {
                // action
            }) {
                Profile()
                    .presentationCornerRadius(32)
                    .presentationDetents([.fraction(0.8375)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThickMaterial)
                    .presentationBackgroundInteraction(.enabled)
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

        context.insert(randomSession)
        
        
//        do {
//            try context.save()
//            print("New random session added at \(selectedDateTime)!")
//        } catch {
//            print("Failed to save new session: \(error.localizedDescription)")
//        }
    }
    
    private func hasSessionForToday() -> Bool {
        return sessions.contains { $0.date.startOfDay == Date().startOfDay }
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
        Sessions()
            .modelContainer(HoopSession.preview)
}
