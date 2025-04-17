//
//  Sessions.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData

// Represents the different types of sheets (modals) that can be displayed.
enum ActiveSheet {
    case stats, profile, sessionCreation, sessionDetails, settings, none
}

// MARK: - Main Sessions View
// This view manages and displays a list of Hoops sessions along with metrics, filtering, and additional UI elements.
struct Sessions: View {
    
    // MARK: - Swift Data Access
    // Access the shared data model context for performing CRUD operations.
    @Environment(\.modelContext) var context
    // Query for HoopSession objects, sorted by date in reverse order with an animated insertion.
    @Query(sort: \HoopSession.date, order: .reverse, animation: .bouncy) var sessions: [HoopSession]
    
    // MARK: - UI State
    // State for managing which modal sheet is active.
    @State private var activeSheet: ActiveSheet = .none
    // State for tracking the currently selected graph metric.
    @State private var selectedMetric: GraphType = .none
    // State for filtering sessions based on the selected shot type.
    @State private var selectedShotType: ShotType = .allShots
    // State for the date that is currently selected (used for filtering sessions).
    @State private var selectedDate: Date = .now

    // MARK: - Session Statistics
    // State properties to hold the computed statistics for sessions.
    @State private var sessionCount = 0
    @State private var totalMakes = 0
    @State private var averageMakesPerMinute = 0.0
    @State private var streak = 0
    
    // MARK: - Session Details
    // Holds the currently selected session. Used for passing details to a session detail view.
    @State var selectedSession: HoopSession = HoopSession(date: .now, makes: 0, length: 0, shotType: .allShots)
    
    // MARK: - Trophy Tracking
    // Dictionary to store previously persisted trophy levels for accolades.
    @State private var previousTrophyLevels: [String: TrophyLevel] = [:]
    // Flag to determine if the trophy upgrade popup should be displayed.
    @State private var showTrophyPopup: Bool = false
    // Stores the accolade that was most recently upgraded.
    @State private var upgradedAccolade: Accolade?
    
    // MARK: - List Filters/Sorting
    // State to control whether filter options are shown.
    @State var showFilters: Bool = false
    // Currently selected shot type filter.
    @State var shotType: ShotType = .allShots
    // Controls the visibility for each shot type filter.
    @State private var shotTypeVisibility: [ShotType: Bool] = [
        .layups: false,
        .freeThrows: false,
        .midrange: false,
        .threePointers: false,
        .deep: false,
        .allShots: false
    ]
        
    // MARK: - Selected Day's Sessions
    // Filters sessions to only include those from the currently selected day.
    private var selectedDaySessions: [HoopSession] {
        sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
    }
    
    
    // MARK: - The UI Body
    // The main view body that lays out the UI components.
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    
                    // Week pager allows the user to swipe through weeks/dates.
                    WeekPagerView(selectedDate: $selectedDate)
                        .padding(.top, 5)
                    
                    VStack(spacing: 20) {
                        // Displays metrics (sessions, total makes, average makes) buttons.
                        metricsView
                        // Displays the list of sessions along with the header and filters.
                        contentView
                    }
                }
                // Background styling for the main content view.
                .background(.ultraThinMaterial)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                // Presents different sheets based on the activeSheet state.
                .sheet(
                    isPresented: Binding(get: { activeSheet != .none },
                                         set: { if !$0 { activeSheet = .none } }),
                    onDismiss: {
                        // Reset the selected metric and refresh stats when the sheet is dismissed.
                        withAnimation {
                            selectedMetric = .none
                            refreshStats()
                        }
                    }
                ) {
                    sheetContent
                }
                // Refresh stats when view appears or when certain state changes.
                .onAppear(perform: refreshStats)
                .onChange(of: sessions) { _, _ in
                    refreshStats()
                }
                .onChange(of: selectedDate) { _, _ in
                    refreshStats()
                }
                
                // Custom overlay for displaying trophy popup when an accolade is upgraded.
                if showTrophyPopup, let trophyAccolade = upgradedAccolade {
                    TrophyPopupView(accolade: trophyAccolade) {
                        withAnimation {
                            showTrophyPopup = false
                        }
                    }
                    .zIndex(10)
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    // Metrics View:
    // Displays buttons for different statistics. Tapping these buttons toggles the stats view.
    private var metricsView: some View {
        HStack(spacing: 10) {
            MetricButton(
                icon: "basketball.fill",
                title: "Sessions",
                value: "\(sessionCount)",
                color: .orange,
                isSelected: withAnimation { selectedMetric == .sessions },
                variant: .compact
            ) { toggleMetric(.sessions) }
            
            MetricButton(
                icon: "scope",
                title: "Total Makes",
                value: "\(totalMakes)",
                color: .red,
                isSelected: withAnimation { selectedMetric == .makes },
                variant: .compact
            ) { toggleMetric(.makes) }
            
            MetricButton(
                icon: "chart.line.uptrend.xyaxis",
                title: "Average Makes",
                value: String(format: "%.2f", averageMakesPerMinute),
                color: .blue,
                isSelected: withAnimation { selectedMetric == .average },
                variant: .expanded
            ) { toggleMetric(.average) }
        }
        .frame(height: 50)
        .padding(.horizontal, 15)
        .padding(.top, 5)
    }
    
    // Content View:
    // Displays the header, filtering options, the session list, and a floating action button for session creation.
    private var contentView: some View {
        VStack {
            // Header view displaying the selected date and filter options.
            HeaderView(shotTypeVisibility: $shotTypeVisibility, selectedDate: $selectedDate)
                .padding(.bottom, 5)
            
            // ZStack containing the session list and an overlay button to add a new session.
            ZStack(alignment: .bottomTrailing) {
                SessionListView(
                    sessions: selectedDaySessions,
                    context: context,
                    selectedSession: $selectedSession,
                    selectedDate: $selectedDate,
                    shotTypeVisibility: shotTypeVisibility,
                    onSessionSelected: { activeSheet = .sessionDetails }
                )
                .padding(.horizontal)
                .background(.black.opacity(0.25))
                .cornerRadius(32)
                .ignoresSafeArea(.all, edges: .bottom)
                
                // Floating button that opens the session creation sheet.
                FloatingActionButton {
                    withAnimation { activeSheet = .sessionCreation }
                }
            }
        }
    }
    
    // Toolbar Content:
    // Defines the content for the navigation bar's toolbar (settings, title, streak).
    private var toolbarContent: some ToolbarContent {
        Group {
            // Left side: Settings gear button that also triggers adding a random session.
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: { activeSheet = .settings }) {
                    Image(systemName: "gear")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                        .frame(width: 20, height: 20)
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                                .foregroundColor(.gray.opacity(0.25))
                        )
                }
                // Disable the button when the trophy popup is showing.
                .disabled(showTrophyPopup)
                .opacity(showTrophyPopup ? 0.33 : 1.0)
            }
            
            // Center: Title button that opens the profile sheet when tapped.
            ToolbarItemGroup(placement: .principal) {
                Button(action: { activeSheet = .profile }) {
                    Text("hoops.")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(height: 20)
                }
                .disabled(showTrophyPopup)
                .opacity(showTrophyPopup ? 0.33 : 1.0)
            }
            
            // Right side: Streak display that shows the current streak if greater than 1.
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { activeSheet = .profile }) {
                    if streak > 1 {
                        HStack(spacing: 5) {
                            ZStack {
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .frame(width: 18, height: 20)
                                    .foregroundStyle(.red)
                                
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 8, height: 10)
                                    .offset(y: 3)
                                    .foregroundStyle(.red)
                                
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .frame(width: 9, height: 11)
                                    .offset(y: 2.5)
                                    .foregroundStyle(.orange)
                            }
                            
                            // Display the streak count.
                            Text("\(streak)")
                                .font(.headline)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: streak)
                        .shadow(color: .red.opacity(0.125), radius: 2.5)
                        .shadow(color: .red.opacity(0.075), radius: 7.5)
                        .shadow(color: .red.opacity(0.025), radius: 15)
                        .frame(width: 50, height: 20)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                                .foregroundColor(.gray.opacity(0.25))
                        )
                    }
                }
                .disabled(showTrophyPopup)
                .opacity(showTrophyPopup ? 0.33 : 1.0)
            }
        }
    }
    
    // MARK: - Sheet Content Builder
    // Presents the appropriate sheet (modal) based on the current activeSheet value.
    @ViewBuilder
    private var sheetContent: some View {
        switch activeSheet {
        case .stats:
            StatsChart(shotType: $shotType, selectedMetric: $selectedMetric, selectedDate: $selectedDate)
                .presentationCornerRadius(32)
                .presentationDetents([.fraction(0.7375)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThickMaterial)
                .presentationBackgroundInteraction(.enabled)
            
        case .profile:
            Profile(
                averageMakesPerMinute: SessionsLogic.calculateAllTimeAverage(for: sessions),
                streak: $streak,
                shotType: $shotType,
                makesCount: SessionsLogic.calculateTotalMakes(for: sessions),
                daysHoopedCount: SessionsLogic.calculateDaysHooped(for: sessions)
            )
            .presentationCornerRadius(32)
            .presentationDetents([.fraction(0.96)])
            .presentationBackground(.ultraThickMaterial)
            .presentationDragIndicator(.visible)
            
        case .sessionCreation:
            SessionCreation()
                .presentationCornerRadius(32)
                .presentationDetents([.fraction(0.3)])
                .presentationBackground(.ultraThickMaterial)
            
        case .sessionDetails:
            SessionDetails(session: $selectedSession)
                .presentationCornerRadius(32)
                .presentationDetents([.fraction(0.3)])
                .presentationBackground(.ultraThickMaterial)
            
        case .settings:
            Settings()
                .presentationCornerRadius(32)
                .presentationDetents([.fraction(0.96)])
                .presentationBackground(.ultraThickMaterial)
            
        case .none:
            EmptyView()
        }
    }
    
    // MARK: - UI Actions
    
    /// Toggles the selected metric and opens/closes the stats sheet.
    /// - Parameter metric: The graph metric to toggle.
    private func toggleMetric(_ metric: GraphType) {
        if activeSheet != .stats {
            activeSheet = .stats
        }
        if selectedMetric != metric {
            withAnimation {
                selectedMetric = metric
            }
        } else {
            activeSheet = .none
            withAnimation {
                selectedMetric = .none
            }
        }
    }
    
    /// Refreshes statistics and streak data using business logic computations.
    /// Also triggers a check for trophy upgrades.
    private func refreshStats() {
        let stats = SessionsLogic.updateStats(for: selectedDaySessions)
        withAnimation {
            sessionCount = stats.count
            totalMakes = stats.totalMakes
            averageMakesPerMinute = stats.average
        }
        withAnimation {
            streak = SessionsLogic.calculateStreak(from: sessions)
        }
        
        // Check and trigger trophy upgrades if any thresholds are reached.
        checkForTrophyUpgrades()
    }
    
    /// Inserts a randomly generated session into the data context.
    private func addRandomSession() {
        let randomSession = SessionsLogic.generateRandomSession(for: selectedDate)
        context.insert(randomSession)
    }
    
    // MARK: - Trophy Persistence & Upgrade Logic
    // These helper functions manage the persistence and checking of trophy levels for accolades.
    
    /// Retrieves the persisted trophy levels from UserDefaults.
    /// - Returns: A dictionary mapping accolade titles to their TrophyLevel.
    private func getPersistedTrophyLevels() -> [String: TrophyLevel] {
        let key = "PreviousTrophyLevels"
        if let saved = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] {
            return saved.reduce(into: [String: TrophyLevel]()) { result, pair in
                result[pair.key] = TrophyLevel(rawValue: pair.value) ?? TrophyLevel.none
            }
        }
        return [:]
    }

    /// Saves the trophy levels to UserDefaults.
    /// - Parameter levels: The trophy levels to persist.
    private func setPersistedTrophyLevels(_ levels: [String: TrophyLevel]) {
        let key = "PreviousTrophyLevels"
        let converted = levels.mapValues { $0.rawValue }
        UserDefaults.standard.set(converted, forKey: key)
    }

    /// Computes accolades based on current sessions and stats.
    /// - Returns: An array of Accolade objects representing different achievements.
    private func computeAccolades() -> [Accolade] {
        let sessionsAccolade = Accolade(
            title: "Sessions",
            value: sessions.count, // overall sessions count
            thresholds: (bronze: 10, silver: 25, gold: 50),
            icon: "basketball.fill"
        )
        let makesAccolade = Accolade(
            title: "Makes",
            value: SessionsLogic.calculateTotalMakes(for: sessions),
            thresholds: (bronze: 200, silver: 500, gold: 1000),
            icon: "scope"
        )
        let daysAccolade = Accolade(
            title: "Days Hooped",
            value: SessionsLogic.calculateDaysHooped(for: sessions),
            thresholds: (bronze: 7, silver: 30, gold: 100),
            icon: "calendar"
        )
        return [sessionsAccolade, makesAccolade, daysAccolade]
    }

    /// Checks if any accolade has been upgraded and displays a trophy popup if a new level is reached.
    /// It updates the persisted trophy levels accordingly.
    private func checkForTrophyUpgrades() {
        var storedLevels = getPersistedTrophyLevels()
        let currentAccolades = computeAccolades()
        
        // If no trophy levels are stored, initialize them without triggering an alert.
        if storedLevels.isEmpty {
            for accolade in currentAccolades {
                let newLevel = trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
                storedLevels[accolade.title] = newLevel
            }
            setPersistedTrophyLevels(storedLevels)
            return
        }
        
        for accolade in currentAccolades {
            let newLevel = trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
            let previousLevel = storedLevels[accolade.title] ?? .none
            
            if newLevel > previousLevel {
                upgradedAccolade = accolade
                withAnimation {
                    showTrophyPopup = true
                }
                storedLevels[accolade.title] = newLevel
                // Only trigger one alert at a time.
                break
            } else {
                storedLevels[accolade.title] = newLevel
            }
        }
        setPersistedTrophyLevels(storedLevels)
    }
}


#Preview {
    Sessions()
        .modelContainer(HoopSession.preview)
}
