import SwiftUI
import Combine
import WatchKit
import HealthKit

struct SessionView: View {
    // MARK: –– Inputs
    let mode: SessionMode
    let shotType: ShotType
    let duration: Int?          // non-nil for challenge only
    @Binding var path: NavigationPath

    // MARK: –– Common State
    @State private var endDate: Date = .now
    @State private var timeCount = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var makes = 0
    @State private var showingEndEarlyConfirmation = false
    @State private var sessionComplete = false
    @State private var hapticTimer: Timer?
    @StateObject private var sessionManager = SessionManager()

    // MARK: –– Drill-Only State
    @State private var startTime = Date()
    @State private var elapsedTime = 0
    @State private var drillTimer: AnyCancellable?
    @State private var currentStage = 1
    @State private var stageMakes = 0
    @State private var showingDrillEndEarlyConfirmation = false

    // MARK: –– View Body
    var body: some View {
        Group {
            if mode == .drill {
                drillBody
            } else {
                standardBody
            }
        }
    }
}

// MARK: –– Subviews
extension SessionView {
    private var drillBody: some View {
        VStack {
            topBar(
                cancelAction: { showingDrillEndEarlyConfirmation = true },
                title: formatTime(seconds: elapsedTime),
                infoAction: {}
            )
            Spacer()
            LogMakeButton(
                makes: $makes,
                currentStage: $currentStage,
                shotType: shotType
            ) {
                stopDrillTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                    path.append(
                        AppRoute.results(
                            mode: .drill,
                            shot: shotType,
                            duration: nil,
                            makes: makes,
                            time: elapsedTime
                        )
                    )
                }
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.container, edges: .top)
        .onAppear {
            if drillTimer == nil { startDrillTimer() }
            sessionManager.beginWorkout(duration: nil)
        }
        .onDisappear {
            stopDrillTimer()
            sessionManager.endWorkout()
        }
        .alert("Abandon Drill?", isPresented: $showingDrillEndEarlyConfirmation) {
            Button("Quit", role: .destructive) {
                sessionManager.discardOnEnd = true
                stopDrillTimer()
                sessionManager.onWorkoutDiscarded = { path = NavigationPath() }
                sessionManager.endWorkout()
            }
            Button("Keep Hoopin’", role: .cancel) { }
        }
    }

    private var standardBody: some View {
        VStack {
            HStack {
                Button(action: { showingEndEarlyConfirmation = true }) {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderless)
                .clipShape(Circle())
                .tint(.red)
                Spacer()
                Text(TimeFormatter.format(seconds: timeCount))
                    .font(.title2).fontWeight(.semibold).fontDesign(.rounded)
                Spacer()
                Text("\(makes)")
                    .font(.title2).fontWeight(.semibold).fontDesign(.rounded)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal)
            .padding(.top, 30)
            .alert(
                mode == .challenge ? "Abandon Challenge?" : "Finish Session?",
                isPresented: $showingEndEarlyConfirmation
            ) {
                if mode == .challenge {
                    Button("Quit", role: .destructive) {
                        sessionManager.discardOnEnd = true
                        stopAllTimers()
                        sessionManager.onWorkoutDiscarded = { path = NavigationPath() }
                    }
                } else {
                    Button("Finish Session", role: .destructive) { manualFinish() }
                }
                Button("Keep Hoopin’", role: .cancel) { }
            }

            Spacer()

            Button {
                makes += 1
                WKInterfaceDevice.current().play(.success)
            } label: {
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.green.opacity(0.35))
                    .offset(y: 65)
            }
            .edgesIgnoringSafeArea(.all)
            .tint(.green)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 40))
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.container, edges: .top)
        .fullScreenCover(isPresented: $sessionComplete) {
            VStack(spacing: 16) {
                Text("Time’s up!").font(.title2).bold()
                Button("View Results") {
                    stopHapticAlarm()
                    path.append(
                        AppRoute.results(
                            mode: mode,
                            shot: shotType,
                            duration: duration,
                            makes: makes,
                            time: timeCount
                        )
                    )
                    sessionComplete = false
                }
                .tint(.green)
                .font(.headline)
            }
            .interactiveDismissDisabled(true)
            .padding()
        }
        .onAppear {
            if mode == .challenge, let limit = duration {
                sessionManager.onSessionExpired = { finishSession() }
                timeCount = limit
                endDate = Date().addingTimeInterval(TimeInterval(limit))
                sessionManager.beginWorkout(duration: TimeInterval(limit))
                startAccurateTimer()
            } else {
                sessionManager.onSessionExpired = nil
                timeCount = 0
                sessionManager.beginWorkout(duration: nil)
                startCountUpTimer()
            }
        }
        .onDisappear {
            stopAllTimers()
        }
    }

    private func topBar(cancelAction: @escaping () -> Void,
                        title: String,
                        infoAction: @escaping () -> Void) -> some View
    {
        HStack(spacing: 2.5) {
            Button(action: cancelAction) {
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderless)
            .clipShape(Circle())
            .tint(.red)

            Spacer()

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .layoutPriority(1)

            Spacer()

            Button(action: infoAction) {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.borderless)
            .clipShape(Circle())
            .tint(.gray)
        }
        .frame(height: 30)
        .padding(.top, 30)
        .padding(.horizontal)
    }
}

// MARK: –– Timer Helpers
private extension SessionView {
    func startDrillTimer() {
        startTime = Date()
        elapsedTime = 0
        makes = 0
        currentStage = 1
        stageMakes = 0
        drillTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                elapsedTime = Int(Date().timeIntervalSince(startTime))
            }
    }

    func stopDrillTimer() {
        drillTimer?.cancel()
        drillTimer = nil
    }

    func startAccurateTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                let remaining = Int(ceil(endDate.timeIntervalSinceNow))
                if remaining > 0 {
                    timeCount = remaining
                } else {
                    timeCount = 0
                    finishSession()
                }
            }
    }

    func startCountUpTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in timeCount += 1 }
    }

    func finishSession() {
        stopAllTimers()
        startHapticAlarm()
        sessionComplete = true
    }

    func manualFinish() {
        sessionManager.onSessionExpired = nil
        stopAllTimers()
        path.append(
            AppRoute.results(
                mode: mode,
                shot: shotType,
                duration: duration,
                makes: makes,
                time: timeCount
            )
        )
    }

    func stopAllTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
        sessionManager.endWorkout()
    }

    private func startHapticAlarm() {
        // create the timer but don't schedule it yet
        let timer = Timer(timeInterval: 1, repeats: true) { _ in
            WKInterfaceDevice.current().play(.notification)
        }
        hapticTimer = timer
        // attach it to the common modes so it fires when the screen is asleep
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopHapticAlarm() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    func formatTime(seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: –– Workout Manager
class SessionManager: NSObject, ObservableObject {
    var onSessionExpired: (() -> Void)?
    var onWorkoutDiscarded: (() -> Void)?
    var discardOnEnd = false

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func beginWorkout(duration: TimeInterval?) {
        discardOnEnd = false
        let config = HKWorkoutConfiguration()
        config.activityType = .basketball
        config.locationType   = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print("⚠️ Couldn't start workout: \(error)")
            return
        }

        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: config
        )

        healthStore.requestAuthorization(
            toShare: [.workoutType()],
            read:   [.workoutType()]
        ) { ok, _ in
            guard ok else { return }
            let start = Date()
            self.session?.startActivity(with: start)
            self.builder?.beginCollection(withStart: start) { _, _ in }
            if let dur = duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
                    self.endWorkout()
                }
            }
        }
    }

    func endWorkout() {
        guard let s = session, s.state == .running else { return }
        s.end()
    }
}

// MARK: –– HKWorkoutSessionDelegate
extension SessionManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from _: HKWorkoutSessionState,
        date: Date
    ) {
        guard toState == .ended else { return }
        builder?.endCollection(withEnd: date) { _, _ in
            DispatchQueue.main.async {
                if self.discardOnEnd {
                    self.builder?.discardWorkout()
                    self.builder = nil
                    self.session = nil
                    self.onWorkoutDiscarded?()
                } else {
                    self.builder?.finishWorkout { _, error in
                        if let error = error {
                            print("⚠️ Workout save error: \(error)")
                        }
                        self.onSessionExpired?()
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout error:", error)
    }
}

// MARK: –– HKLiveWorkoutBuilderDelegate
extension SessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ builder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) { }
    func workoutBuilderDidCollectEvent(_ builder: HKLiveWorkoutBuilder) { }
}

// MARK: –– LogMakeButton
struct LogMakeButton: View {
    @Binding var makes: Int
    @Binding var currentStage: Int
    let shotType: ShotType
    @State private var stageMakes = 0
    private var totalStages: Int { shotType.shots.count }
    let onComplete: () -> Void

    var body: some View {
        Button {
            WKInterfaceDevice.current().play(.success)
            handleStageProgress()
            makes += 1
        } label: {
            VStack(spacing: 5) {
                Spacer()

                // Top row: exactly 2 icons
                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { idx in
                        iconView(filled: stageMakes > idx)
                    }
                }

                // Bottom row: exactly (totalStages - 2) icons
                HStack(spacing: 10) {
                    ForEach(0..<max(0, totalStages - 2), id: \.self) { idx in
                        iconView(filled: stageMakes > idx + 2)
                    }
                }

                Spacer()

                Text(shotType.shots[currentStage - 1])
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
            }
        }
        .edgesIgnoringSafeArea(.all)
        .tint(.green)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 40))
    }

    private func handleStageProgress() {
        if stageMakes < 4 {
            stageMakes += 1
        } else {
            stageMakes += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    stageMakes = 0
                    if currentStage < totalStages {
                        currentStage += 1
                    } else {
                        onComplete()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func iconView(filled: Bool) -> some View {
        Image(systemName: "basketball.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 35)
            .fontWeight(.semibold)
            .foregroundStyle(.green.opacity(filled ? 0.75 : 0.25))
            .animation(.easeIn(duration: 0.25), value: filled)
    }
}


// MARK: –– Previews
struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(
            mode: .freestyle,
            shotType: .layups,
            duration: nil,
            path: .constant(NavigationPath())
        )
        .previewDisplayName("Drill Mode")
    }
}
