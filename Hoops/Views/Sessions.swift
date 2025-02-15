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
    
    @State var showFilters: Bool = false
    
    @State private var shotTypeVisibility: [ShotType: Bool] = [
        .layups: false,
        .freeThrows: false,
        .midrange: false,
        .threePointers: false,
        .deep: false,
        .allShots: false
    ]


    private var selectedDaySessions: [HoopSession] {
        sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                WeekView(selectedDate: $selectedDate)
                    .padding(.top, 5)
                
                VStack(spacing: 20) {
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
                    .padding(.top, 5)
                    
                    VStack {
                        HStack {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(selectedDate, style: .date)
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                                .contentTransition(.numericText())
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                                .padding(5)
                                .padding(.horizontal, 5)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .buttonStyle()
                            }
                            
                            Button(action: {
                                withAnimation {
                                    showFilters.toggle()
                                }
                            }) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .buttonStyle()
                            }
                        }
                        
                        if showFilters {
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation {
                                            shotTypeVisibility[.layups]?.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("Layups")
                                                .foregroundStyle(.red)
                                                .opacity(shotTypeVisibility[.layups] == true ? 1 : 0.8)
                                        }
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(.ultraThinMaterial)
                                        .background(shotTypeVisibility[.layups] == true ? .red.opacity(0.5) : .clear)
                                        .cornerRadius(20)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            shotTypeVisibility[.freeThrows]?.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("Free Throws")
                                                .foregroundStyle(.blue)
                                                .opacity(shotTypeVisibility[.freeThrows] == true ? 1 : 0.8)
                                        }
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(.ultraThinMaterial)
                                        .background(shotTypeVisibility[.freeThrows] == true ? .blue.opacity(0.5) : .clear)
                                        .cornerRadius(20)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            shotTypeVisibility[.midrange]?.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("Midrange")
                                                .foregroundStyle(.blue)
                                                .opacity(shotTypeVisibility[.midrange] == true ? 1 : 0.8)
                                        }
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(.ultraThinMaterial)
                                        .background(shotTypeVisibility[.midrange] == true ? .blue.opacity(0.5) : .clear)
                                        .cornerRadius(20)
                                    }
                                }
                                
                                HStack {
                                    Spacer()
                                    
                                    if shotTypeVisibility.values.contains(true) {
                                        Button(action: {
                                            withAnimation {
                                                for key in shotTypeVisibility.keys {
                                                    shotTypeVisibility[key] = false
                                                }
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "xmark")
                                                    .foregroundStyle(.gray)
                                            }
                                            .padding(5)
                                            .padding(.horizontal, 5)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(20)
                                        }
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            shotTypeVisibility[.threePointers]?.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("Threes")
                                                .foregroundStyle(.green)
                                                .opacity(shotTypeVisibility[.threePointers] == true ? 1 : 0.8)
                                        }
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(.ultraThinMaterial)
                                        .background(shotTypeVisibility[.threePointers] == true ? .green.opacity(0.5) : .clear)
                                        .cornerRadius(20)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            shotTypeVisibility[.deep]?.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("Deep")
                                                .foregroundStyle(.purple)
                                                .opacity(shotTypeVisibility[.deep] == true ? 1 : 0.8)
                                        }
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(.ultraThinMaterial)
                                        .background(shotTypeVisibility[.deep] == true ? .purple.opacity(0.5) : .clear)
                                        .cornerRadius(20)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            shotTypeVisibility[.allShots]?.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("All Shots")
                                                .foregroundStyle(.orange)
                                                .opacity(shotTypeVisibility[.allShots] == true ? 1 : 0.8)
                                        }
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(.ultraThinMaterial)
                                        .background(shotTypeVisibility[.allShots] == true ? .orange.opacity(0.5) : .clear)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.top, 2.5)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                            .contentTransition(.numericText())
                            .foregroundStyle(.orange)
                            .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    
                    ZStack(alignment: .bottomTrailing) {
                        SessionListView(sessions: selectedDaySessions, context: context, selectedSession: $selectedSession, selectedDate: $selectedDate, shotTypeVisibility: shotTypeVisibility, onSessionSelected: {
                            activeSheet = .sessionDetails
                        })
                        .padding(.horizontal)
                        FloatingActionButton {
                            withAnimation { activeSheet = .sessionCreation }
                        }
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
        let shotTypeToAdd = ShotType.allCases.randomElement() ?? .allShots
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
            shotType: shotTypeToAdd,
            sessionType: SessionType.allCases.randomElement() ?? .freestyle
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
    @Binding var selectedDate: Date // Added binding to track date change
    let shotTypeVisibility: [ShotType: Bool]
    let onSessionSelected: () -> Void

    let sessionTypes: [String] = ["Freestyle", "Challenge", "Drill"]

    var groupedSessions: [String: [HoopSession]] {
        // Check if all toggles are false
        let allTogglesOff = shotTypeVisibility.values.allSatisfy { !$0 }

        // Determine which sessions to show
        let filteredSessions = allTogglesOff ? sessions : sessions.filter { session in
            shotTypeVisibility[session.shotType] == true
        }

        // Group sessions by sessionType
        var grouped = Dictionary(grouping: filteredSessions, by: { $0.sessionType.rawValue })

        // Ensure every session type appears, even if empty
        for type in sessionTypes {
            if grouped[type] == nil {
                grouped[type] = []
            }
        }

        return grouped
    }

    var body: some View {
        ScrollViewReader { proxy in
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
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)

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
                                    .id(session.id)
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Text(promptText(for: sessionType))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.gray.opacity(0.75))
                                        .padding(.horizontal)
                                        .frame(height: 45)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            }
                        }
                    }
                    Spacer(minLength: 250)
                }
                .scrollIndicators(.hidden)
                .animation(.smooth, value: sessions)
            }
            .scrollIndicators(.hidden)
            .id(selectedDate)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .ignoresSafeArea()
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
    
    func iconColor(for sessionType: String) -> Color {
        switch sessionType {
            case "Freestyle": return .red
            case "Challenge": return .blue
            case "Drill": return .green
            default: return .white
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
