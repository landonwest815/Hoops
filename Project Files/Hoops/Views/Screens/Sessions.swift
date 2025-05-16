// Sessions.swift
// Hoops
//
// Created by Landon West on 1/3/24.

import SwiftUI
import SwiftData

enum ActiveSheet {
    case stats, profile, sessionCreation, sessionDetails, settings, none
}

enum SortMode {
    case byTime
    case byShotType
}

struct Sessions: View {
    @Environment(\.modelContext) var context
    @Query(animation: .bouncy) var sessions: [HoopSession]

    @State private var activeSheet: ActiveSheet = .none
    @State private var selectedMetric: GraphType = .none
    @State private var selectedShotType: ShotType = .allShots
    @State private var selectedDate: Date = .now

    @State private var sessionCount = 0
    @State private var totalMakes = 0
    @State private var averageMakesPerMinute = 0.0
    @State private var streak = 0

    @State var selectedSession: HoopSession = HoopSession(date: .now, makes: 0, length: 0, shotType: .allShots)

    @State private var previousTrophyLevels: [String: TrophyLevel] = [:]
    @State private var showTrophyPopup: Bool = false
    @State private var upgradedAccolade: Accolade?

    @State var showFilters: Bool = false
    @State var shotType: ShotType = .allShots
    @State private var shotTypeVisibility: [ShotType: Bool] = [
        .layups: false, .freeThrows: false, .midrange: false,
        .threePointers: false, .deep: false, .allShots: false
    ]
    
    @State private var sortMode: SortMode = .byTime

    @AppStorage(AppSettingsKeys.dateFormat) private var dateFormat: String = "M dd, yyyy"
    @AppStorage(AppSettingsKeys.startOfWeek) private var startOfWeek: String = "Sunday"

    @Binding var showOnboarding: Bool
    
    
    private var selectedDaySessions: [HoopSession] {
        sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
    }

    private var isTodayVisible: Bool {
        Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: .weekOfYear)
    }

    private func jumpToToday() {
        withAnimation { selectedDate = .now }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    WeekPagerView(selectedDate: $selectedDate)
                        .padding(.top, 5)

                    VStack(spacing: 20) {
                        metricsView
                        contentView
                    }
                }
                .background(.ultraThinMaterial)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .sheet(
                    isPresented: Binding(get: { activeSheet != .none }, set: { if !$0 { activeSheet = .none } }),
                    onDismiss: {
                        withAnimation {
                            selectedMetric = .none
                            refreshStats()
                        }
                    }
                ) {
                    sheetContent
                }
                .onAppear(perform: refreshStats)
                .onChange(of: sessions) { _, _ in refreshStats() }
                .onChange(of: selectedDate) { _, _ in refreshStats() }

                if showTrophyPopup, let trophyAccolade = upgradedAccolade {
                    TrophyPopupView(accolade: trophyAccolade) {
                        withAnimation { showTrophyPopup = false }
                    }
                    .zIndex(10)
                }
            }
        }
    }

    private var metricsView: some View {
        HStack(spacing: 10) {
            MetricButton(icon: "basketball.fill", title: "Sessions", value: "\(sessionCount)", color: .orange, isSelected: selectedMetric == .sessions, variant: .compact) {
                toggleMetric(.sessions)
            }

            MetricButton(icon: "scope", title: "Total Makes", value: "\(totalMakes)", color: .red, isSelected: selectedMetric == .makes, variant: .compact) {
                toggleMetric(.makes)
            }

            MetricButton(icon: "chart.line.uptrend.xyaxis", title: "Average Makes", value: String(format: "%.2f", averageMakesPerMinute), color: .blue, isSelected: selectedMetric == .average, variant: .expanded) {
                toggleMetric(.average)
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 15)
        .padding(.top, 5)
    }

    private var contentView: some View {
        VStack {
            HeaderView(
                shotTypeVisibility: $shotTypeVisibility,
                selectedDate: $selectedDate,
                sortMode: $sortMode
            )
            .padding(.bottom, 5)

            ZStack(alignment: .bottomTrailing) {
                SessionListView(
                    sessions: sessions,
                    context: context,
                    selectedSession: $selectedSession,
                    selectedDate: $selectedDate,
                    shotTypeVisibility: shotTypeVisibility,
                    sortMode: sortMode,
                    onSessionSelected: { activeSheet = .sessionDetails }
                )
                .background(.black.opacity(0.25))
                .cornerRadius(32)
                .ignoresSafeArea(.all, edges: .bottom)

                FloatingActionButton {
                    withAnimation { activeSheet = .sessionCreation }
                }
            }
        }
    }

    private var toolbarContent: some ToolbarContent {
        Group {
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
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(style: StrokeStyle(lineWidth: 1)).foregroundColor(.gray.opacity(0.25)))
                }
                .disabled(showTrophyPopup)
                .opacity(showTrophyPopup ? 0.33 : 1.0)
            }

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

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { if !isTodayVisible { jumpToToday() } }) {
                    HStack(spacing: 5) {
                        if isTodayVisible {
                            StreakBadgeView(streak: streak)
                        } else {
                            Text("Today").font(.system(size: 14)).fontWeight(.semibold).fontDesign(.rounded).foregroundStyle(.white)
                            Image(systemName: "arrow.forward").font(.system(size: 9)).fontWeight(.bold).foregroundStyle(.white)
                        }
                    }
                    .frame(width: 75, height: 30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(style: StrokeStyle(lineWidth: 1)).foregroundColor(.gray.opacity(0.25)))
                    .animation(.easeInOut(duration: 0.25), value: isTodayVisible)
                }
                .disabled(showTrophyPopup)
                .opacity(showTrophyPopup ? 0.33 : 1.0)
            }
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        switch activeSheet {
        case .stats:
            StatsChart(shotType: $shotType, selectedMetric: $selectedMetric, selectedDate: $selectedDate)
                .sheetStyle()
                .presentationDetents([.fraction(AppConstants.SheetHeights.statsFraction)])
                .presentationBackgroundInteraction(.enabled)

        case .profile:
            Profile(
                averageMakesPerMinute: SessionsLogic.calculateAllTimeAverage(for: sessions),
                streak: $streak,
                shotType: $shotType,
                makesCount: SessionsLogic.calculateTotalMakes(for: sessions),
                daysHoopedCount: SessionsLogic.calculateDaysHooped(for: sessions)
            )
            .sheetStyle()
            .presentationDetents([.fraction(AppConstants.SheetHeights.profileFraction)])

        case .sessionCreation:
            SessionCreation(selectedDate: $selectedDate)
                .sheetStyle()
                .presentationDetents([.fraction(AppConstants.SheetHeights.creationFraction)])
                .presentationDragIndicator(.hidden)

        case .sessionDetails:
            SessionDetails(session: $selectedSession)
                .sheetStyle()
                .presentationDetents([.fraction(AppConstants.SheetHeights.detailsFraction)])
                .presentationDragIndicator(.hidden)
            
        case .settings:
            Settings(showOnboarding: $showOnboarding)
                .sheetStyle()
                .presentationDetents([.fraction(AppConstants.SheetHeights.settingsFraction)])

        case .none:
            EmptyView()
        }
    }

    private func toggleMetric(_ metric: GraphType) {
        if activeSheet != .stats {
            activeSheet = .stats
        }
        if selectedMetric != metric {
            withAnimation { selectedMetric = metric }
        } else {
            activeSheet = .none
            withAnimation { selectedMetric = .none }
        }
    }

    private func refreshStats() {
        let stats = SessionsLogic.updateStats(for: selectedDaySessions)
        withAnimation {
            sessionCount = stats.count
            totalMakes = stats.totalMakes
            averageMakesPerMinute = stats.average
        }
        withAnimation {
            streak = SessionsLogic.calculateWeeklyStreak(from: sessions)
        }
        checkForTrophyUpgrades()
    }

    private func checkForTrophyUpgrades() {
        var storedLevels = AccoladeLogic.getPersistedTrophyLevels()

        if storedLevels.isEmpty {
            let current = AccoladeLogic.computeAccolades(for: sessions)
            for accolade in current {
                storedLevels[accolade.title] = trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
            }
            AccoladeLogic.setPersistedTrophyLevels(storedLevels)
            return
        }

        if let upgrade = AccoladeLogic.checkForTrophyUpgrade(from: sessions, storedLevels: &storedLevels) {
            upgradedAccolade = upgrade
            withAnimation { showTrophyPopup = true }
        }

        AccoladeLogic.setPersistedTrophyLevels(storedLevels)
    }
}

#Preview {
    @Previewable @State var showOnboarding = false
    Sessions(showOnboarding: $showOnboarding).modelContainer(HoopSession.preview)
}
