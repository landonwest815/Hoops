import SwiftUI
import SwiftData

enum ActiveSheet {
    case stats, profile, sessionCreation, sessionDetails, settings, none
}

enum SortMode {
    case byTime, byShotType
}

struct Sessions: View {
    @Environment(\.modelContext) private var context
    @Query(animation: .bouncy) private var sessions: [HoopSession]

    @State private var activeSheet: ActiveSheet = .none
    @State private var selectedMetric: GraphType = .none
    @State private var selectedShotType: ShotType = .allShots
    @State private var selectedDate: Date = .now

    @State private var sessionCount = 0
    @State private var totalMakes = 0
    @State private var averageMakesPerMinute = 0.0
    @State private var streak = 0

    @State private var selectedSession = HoopSession(date: .now, makes: 0, length: 0, shotType: .allShots)
    @State private var previousTrophyLevels: [String: TrophyLevel] = [:]
    @State private var showTrophyPopup = false
    @State private var upgradedAccolade: Accolade?

    @State private var shotTypeVisibility: [ShotType: Bool] = [
        .layups: false, .freeThrows: false, .midrange: false,
        .threePointers: false, .deep: false, .allShots: false
    ]
    @State private var sortMode: SortMode = .byTime

    @AppStorage(AppSettingsKeys.dateFormat) private var dateFormat = "MMM d, yyyy"
    @AppStorage(AppSettingsKeys.startOfWeek)  private var startOfWeek = "Sunday"

    @Binding var showOnboarding: Bool

    private var selectedDaySessions: [HoopSession] {
        sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
    }

    private var isTodayVisible: Bool {
        Calendar.current.isDate(selectedDate, equalTo: .now, toGranularity: .weekOfYear)
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
                .sheet(
                    isPresented: Binding(
                        get: { activeSheet != .none },
                        set: { if !$0 { activeSheet = .none } }
                    ),
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

                if showTrophyPopup, let accolade = upgradedAccolade {
                    TrophyPopupView(accolade: accolade) {
                        withAnimation { showTrophyPopup = false }
                    }
                    .zIndex(10)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        openSheet(.settings)
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.gray)
                            .padding(5)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(style: .init(lineWidth: 1))
                                    .foregroundColor(.gray.opacity(0.25))
                            )
                    }
                    .disabled(showTrophyPopup)
                    .opacity(showTrophyPopup ? 0.33 : 1.0)
                }

                ToolbarItemGroup(placement: .principal) {
                    Button {
                        openSheet(.profile)
                    } label: {
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
                    Button {
                        if !isTodayVisible {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedDate = .now
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if isTodayVisible {
                                StreakBadgeView(streak: streak)
                            } else {
                                Text("Today")
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.white)
                                Image(systemName: "arrow.forward")
                                    .font(.system(size: 9))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 75, height: 30)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(style: .init(lineWidth: 1))
                                .foregroundColor(.gray.opacity(0.25))
                        )
                    }
                    .disabled(showTrophyPopup || isTodayVisible)
                    .opacity(showTrophyPopup ? 0.33 : 1.0)
                }
            }
        }
    }

    private var metricsView: some View {
        HStack(spacing: 10) {
            MetricButton(
                icon: "basketball.fill",
                title: "Sessions",
                value: "\(sessionCount)",
                color: .orange,
                isSelected: selectedMetric == .sessions,
                variant: .compact
            ) { toggleMetric(.sessions) }

            MetricButton(
                icon: "scope",
                title: "Total Makes",
                value: "\(totalMakes)",
                color: .red,
                isSelected: selectedMetric == .makes,
                variant: .compact
            ) { toggleMetric(.makes) }

            MetricButton(
                icon: "chart.line.uptrend.xyaxis",
                title: "Average Makes",
                value: String(format: "%.2f", averageMakesPerMinute),
                color: .blue,
                isSelected: selectedMetric == .average,
                variant: .expanded
            ) { toggleMetric(.average) }
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

    @ViewBuilder
    private var sheetContent: some View {
        switch activeSheet {
        case .stats:
            StatsChart(
                shotType: $selectedShotType,
                selectedMetric: $selectedMetric,
                selectedDate: $selectedDate
            )
            .sheetStyle()
            .presentationDetents([.fraction(AppConstants.SheetHeights.statsFraction)])
            .presentationBackgroundInteraction(.enabled)

        case .profile:
            Profile(
                averageMakesPerMinute: SessionsLogic.calculateAllTimeAverage(for: sessions),
                streak: $streak,
                shotType: $selectedShotType,
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
        withAnimation {
            if selectedMetric == metric {
                selectedMetric = .none
                activeSheet = .none
            } else {
                selectedMetric = metric
                activeSheet = .stats
            }
        }
    }

    private func refreshStats() {
        let stats = SessionsLogic.updateStats(for: selectedDaySessions)
        withAnimation {
            sessionCount = stats.count
            totalMakes = stats.totalMakes
            averageMakesPerMinute = stats.average
            streak = SessionsLogic.calculateWeeklyStreak(from: sessions)
        }
        checkForTrophyUpgrades()
    }

    private func checkForTrophyUpgrades() {
        var levels = AccoladeLogic.loadTrophyLevels()
        if levels.isEmpty {
            let current = AccoladeLogic.computeAccolades(for: sessions)
            current.forEach {
                levels[$0.title] = trophyLevel(for: $0.value, thresholds: $0.thresholds)
            }
            AccoladeLogic.saveTrophyLevels(levels)
            return
        }
        if let upgrade = AccoladeLogic.checkForTrophyUpgrade(sessions: sessions, currentLevels: &levels) {
            upgradedAccolade = upgrade
            withAnimation { showTrophyPopup = true }
        }
        AccoladeLogic.saveTrophyLevels(levels)
    }

    private func openSheet(_ sheet: ActiveSheet) {
        if activeSheet != .none && activeSheet != sheet {
            activeSheet = .none
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation { activeSheet = sheet }
            }
        } else {
            withAnimation { activeSheet = sheet }
        }
    }
}

#Preview {
    @Previewable @State var showOnboarding = false
    Sessions(showOnboarding: $showOnboarding)
        .modelContainer(HoopSession.preview)
}
