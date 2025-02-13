//
//  Sessions.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData

enum ActiveSheet {
    case stats, profile, sessionCreation, sessionDetails, none
}

struct Sessions: View {
    @Environment(\.modelContext) var context
    @Query(sort: \HoopSession.date, order: .reverse, animation: .bouncy) var sessions: [HoopSession]
    
    // UI State
    @State private var activeSheet: ActiveSheet = .none
    @State private var selectedMetric: GraphType = .none
    @State private var selectedShotType: ShotType = .allShots
    @State private var selectedDate: Date = .now

    // Session Statistics
    @State private var sessionCount = 0
    @State private var totalMakes = 0
    @State private var averageMakesPerMinute = 0.0
    @State private var streak = 0
    
    // Session Details
    @State var selectedSession: HoopSession = HoopSession(date: .now, makes: 0, length: 0, shotType: .allShots)

    private var selectedDaySessions: [HoopSession] {
        sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                WeekView(selectedDate: $selectedDate)
                    .padding(.top, 5)
                
                HStack(spacing: 10) {
                    MetricButton(
                        icon: "basketball.fill",
                        title: "Sessions",
                        value: "\(sessionCount)",
                        color: .orange,
                        isSelected: selectedMetric == .sessions,
                        variant: .compact
                    ) {
                        withAnimation {
                            toggleMetric(.sessions)
                        }
                    }
                    
                    MetricButton(
                        icon: "scope",
                        title: "Total Makes",
                        value: "\(totalMakes)",
                        color: .red,
                        isSelected: selectedMetric == .makes,
                        variant: .compact
                    ) {
                        withAnimation {
                            toggleMetric(.makes)
                        }
                    }
                    
                    MetricButton(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Average Makes",
                        value: String(format: "%.2f", averageMakesPerMinute),
                        color: .blue,
                        isSelected: selectedMetric == .average,
                        variant: .expanded
                    ) {
                        withAnimation {
                            toggleMetric(.average)
                        }
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                
                HStack {
                    Text(selectedDate, style: .date)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.up.arrow.down")
                            .buttonStyle()
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .buttonStyle()
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                
                ZStack(alignment: .bottomTrailing) {
                    SessionListView(sessions: selectedDaySessions, context: context, selectedSession: $selectedSession, onSessionSelected: {
                        activeSheet = .sessionDetails
                    })
                    FloatingActionButton {
                        withAnimation { activeSheet = .sessionCreation }
                    }
                }
            }
            .background(.ultraThinMaterial)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: { addRandomSession() }) {
                        Image(systemName: "gearshape.fill").iconStyle()
                    }
                }
                
                ToolbarItemGroup(placement: .principal) {
                    Button(action: { activeSheet = .profile }) {
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
                            }
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "calendar").iconStyle()
                    }
                }
            }
            .sheet(
                isPresented: Binding(
                    get: { activeSheet != .none },
                    set: { if !$0 { activeSheet = .none } }
                ),
               onDismiss: {
                   withAnimation {
                       selectedMetric = .none
                       updateStats()
                   }
               }
            ) {
                switch activeSheet {
                case .stats:
                    Stats(shotType: $selectedShotType, selectedMetric: $selectedMetric)
                        .presentationCornerRadius(32)
                        .presentationDetents([.fraction(0.6875)])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.ultraThickMaterial)
                        .presentationBackgroundInteraction(.enabled)
                    
                case .profile:
                    Profile()
                        .presentationCornerRadius(32)
                        .presentationDetents([.fraction(0.8375)])
                        .presentationBackground(.ultraThickMaterial)
                    
                case .sessionCreation:
                    CardView()
                        .presentationCornerRadius(32)
                        .presentationDetents([.fraction(0.3)])
                        .presentationBackground(.ultraThickMaterial)
                    
                case .sessionDetails:
                    SessionDetails(session: $selectedSession)
                        .presentationCornerRadius(32)
                        .presentationDetents([.fraction(0.3)])
                        .presentationBackground(.ultraThickMaterial)
                    
                    
                case .none:
                    EmptyView()
                }
                
            }
            .onAppear(perform: {
                updateStats()
                calculateStreak()
            })
//            .onAppear {
//                for session in sessions {
//                    if session.sessionType == nil {
//                        session.sessionType = .freestyle
//                    }
//                }
//                try? context.save() // Save updated sessions
//            }
            .onChange(of: sessions) {
                updateStats()
                calculateStreak()
            }
            .onChange(of: selectedDate) {
                updateStats()
                calculateStreak()
            }
        }
    }
    
    private func toggleMetric(_ metric: GraphType) {
        if selectedMetric != metric {
            activeSheet = .stats
            selectedMetric = metric
        } else {
            activeSheet = .none
            selectedMetric = .none
        }
    }

    private func updateStats() {
        sessionCount = selectedDaySessions.count
        totalMakes = selectedDaySessions.reduce(0) { $0 + $1.makes }
        let totalTime = selectedDaySessions.reduce(0) { $0 + $1.length }
        averageMakesPerMinute = totalTime > 0 ? Double(totalMakes) / Double(totalTime) * 60 : 0
    }
    
    private func addRandomSession() {
        let shotTypeToAdd = selectedShotType
        let currentTime = Date()

        let calendar = Calendar.current
        var selectedDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: currentTime),
            minute: calendar.component(.minute, from: currentTime),
            second: calendar.component(.second, from: currentTime),
            of: selectedDate
        ) ?? selectedDate

        selectedDateTime = selectedDateTime.addingTimeInterval(Double.random(in: 0.001...0.999))

        let randomSession = HoopSession(
            date: selectedDateTime,
            makes: Int.random(in: 5...40),
            length: Int.random(in: 60...600),
            shotType: shotTypeToAdd
        )

        context.insert(randomSession)
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
            withAnimation { streak = 0 }
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

        withAnimation { streak = currentStreak }
    }
}

extension Image {
    func iconStyle() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22, height: 22)
            .foregroundStyle(.gray)
            .fontWeight(.semibold)
    }
    
    func buttonStyle() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 17.5, height: 17.5)
            .foregroundStyle(.orange)
            .fontWeight(.semibold)
            .padding(6)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}

enum MetricButtonVariant {
    case compact
    case expanded
}

struct MetricButton: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let isSelected: Bool
    let variant: MetricButtonVariant
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                        .foregroundStyle(color)
                        .fontWeight(.semibold)
                    
                    Text(value)
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText())
                        .foregroundStyle(.white)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: variant == .compact ? 105 : .infinity) // Dynamically set maxWidth
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .overlay(
                isSelected ? RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.66), lineWidth: 2.5)
                : nil
            )
        }
    }
}

struct SessionListView: View {
    let sessions: [HoopSession]
    let context: ModelContext
    @Binding var selectedSession: HoopSession
    let onSessionSelected: () -> Void // Callback
    
    let sessionTypes: [String] = ["Freestyle", "Challenge", "Drill"] // Define all session types

    var groupedSessions: [String: [HoopSession]] {
        var grouped = Dictionary(grouping: sessions, by: { $0.sessionType.rawValue })
        for type in sessionTypes {
            if grouped[type] == nil {
                grouped[type] = [] // Ensure each session type has an entry
            }
        }
        return grouped
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 25) {
                ForEach(sessionTypes, id: \.self) { sessionType in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: iconName(for: sessionType))
                            Text(sessionType)
                            
                            Spacer()
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .foregroundStyle(.gray)

                        if let sessions = groupedSessions[sessionType], !sessions.isEmpty {
                            ForEach(sessions, id: \.id) { session in
                                SessionThumbnail(
                                    date: session.date,
                                    makes: session.makes,
                                    length: session.length,
                                    average: Double(session.makes) / (Double(session.length) / 60.0),
                                    shotType: session.shotType
                                )
                                .transition(.identity)
                                .contextMenu {
                                    Button {
                                        print("Edit Session")
                                    } label: {
                                        Label("Edit Session", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        withAnimation {
                                            context.delete(session)
                                        }
                                    } label: {
                                        Label("Delete Session", systemImage: "trash")
                                    }
                                }
                                .onTapGesture {
                                    selectedSession = session
                                    onSessionSelected()
                                }
                                .frame(height: 75)
                                .padding(.horizontal)
                            }
                        } else {
                            
                            HStack {
                                Spacer()
                                
                                Text(promptText(for: sessionType))
                                    .font(.subheadline)
                                    .foregroundStyle(.gray.opacity(0.6))
                                    .padding(.horizontal)
                                    .frame(height: 45)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                            }
                            
                        }
                    }
                }
            }
            .animation(.smooth, value: sessions)
        }
    }
    
    func iconName(for sessionType: String) -> String {
        switch sessionType {
        case "Freestyle": return "figure.cooldown"
        case "Challenge": return "figure.bowling"
        case "Drill": return "figure.basketball"
        default: return "questionmark.circle"
        }
    }
    
    func promptText(for sessionType: String) -> String {
        switch sessionType {
        case "Freestyle": return "Shoot hoops!"
        case "Challenge": return "Challenge yourself!"
        case "Drill": return "Hit some Drills!"
        default: return "Shoot hoops!"
        }
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 15) {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 66)
                    
                    Image(systemName: "basketball.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom)
    }
}


#Preview {
        Sessions()
            .modelContainer(HoopSession.preview)
}
