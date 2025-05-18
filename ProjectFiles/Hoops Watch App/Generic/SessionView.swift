import SwiftUI
import Combine
import WatchKit
import HealthKit

struct SessionView: View {
    let mode: SessionMode
    let shotType: ShotType
    let duration: Int?
    @Binding var path: NavigationPath

    @State private var endDate = Date()
    @State private var timeCount = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var makes = 0
    @State private var showingEndEarlyConfirmation = false
    @State private var sessionComplete = false
    @State private var hapticTimer: Timer?
    @StateObject private var sessionManager = SessionManager()

    @State private var startTime = Date()
    @State private var elapsedTime = 0
    @State private var drillTimer: AnyCancellable?
    @State private var currentStage = 1
    @State private var stageMakes = 0
    @State private var showingDrillEndEarlyConfirmation = false

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

private extension SessionView {
    var drillBody: some View {
        VStack {
            topBar(
                cancelAction: { showingDrillEndEarlyConfirmation = true },
                title: formatTime(elapsedTime),
                infoAction: {}
            )
            Spacer()
            DrillButton(
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
        .alert("Abandon Drill?", isPresented: $showingDrillEndEarlyConfirmation) {
            Button("Quit", role: .destructive) {
                // tell the builder to throw it away
                sessionManager.discardOnEnd = true
                stopDrillTimer()

                // when it's discarded, go back to home
                sessionManager.onWorkoutDiscarded = { path = NavigationPath() }

                // THIS is the ONLY other place we call endWorkout()
                sessionManager.endWorkout()
            }
            Button("Keep Hoopin’", role: .cancel) { }
        }
    }

    var standardBody: some View {
        VStack {
            HStack {
                Button { showingEndEarlyConfirmation = true } label: {
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
                        // …unchanged challenge logic…
                    }
                } else {
                    Button("Finish Session", role: .destructive) {
                        // 1) stop your UI timers & haptics
                        stopAllTimers()

                        // 2) disable the auto‐navigate callback so it won’t fire
                        sessionManager.onSessionExpired = nil

                        // 3) end the workout
                        sessionManager.discardOnEnd = false
                        sessionManager.endWorkout()

                        // 4) manually navigate exactly once
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
                // challenge: show cover when time’s up
                sessionManager.onSessionExpired = { finishSession() }
                timeCount = limit
                endDate = Date().addingTimeInterval(TimeInterval(limit))
                sessionManager.beginWorkout(duration: TimeInterval(limit))
                startAccurateTimer()
            } else {
                // freestyle (and drill): auto‐navigate to results
                timeCount = 0
                sessionManager.onSessionExpired = {
                    DispatchQueue.main.async {
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
                }
                sessionManager.beginWorkout(duration: nil)
                startCountUpTimer()
            }
        }
    }

    func topBar(cancelAction: @escaping () -> Void,
                title: String,
                infoAction: @escaping () -> Void) -> some View {
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

    // Timer Helpers
    func startDrillTimer() {
        startTime = Date()
        elapsedTime = 0
        makes = 0
        currentStage = 1
        stageMakes = 0
        drillTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in elapsedTime = Int(Date().timeIntervalSince(startTime)) }
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
        // stop all UI timers & haptics
        stopAllTimers()

        // tell HealthKit to finish the workout, which will fire onSessionExpired
        sessionManager.discardOnEnd = false
        sessionManager.endWorkout()
    }

    func stopAllTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil

        hapticTimer?.invalidate()
        hapticTimer = nil

        // ⚠️ Do NOT call sessionManager.endWorkout() here!
    }

    func startHapticAlarm() {
        let timer = Timer(timeInterval: 1, repeats: true) { _ in
            WKInterfaceDevice.current().play(.notification)
        }
        hapticTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopHapticAlarm() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

class SessionManager: NSObject, ObservableObject {
    var onSessionExpired: (() -> Void)?
    var onWorkoutDiscarded: (() -> Void)?
    var discardOnEnd = false

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func beginWorkout(duration: TimeInterval?) {
        // assume HK authorization already resolved
        let config = HKWorkoutConfiguration()
        config.activityType = .basketball
        config.locationType   = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore,
                                           configuration: config)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print("Workout start failed:", error)
            return
        }

        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: config
        )

        let start = Date()
        session?.startActivity(with: start)
        builder?.beginCollection(withStart: start) { _, _ in }

        if let dur = duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
                self.endWorkout()
            }
        }
    }

    func endWorkout() {
        guard let session = session, session.state == .running else { return }
        session.end()
    }
}

extension SessionManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from _: HKWorkoutSessionState,
        date: Date
    ) {
        guard toState == .ended, let builder = builder else { return }
        builder.endCollection(withEnd: date) { _, _ in
            DispatchQueue.main.async {
                if self.discardOnEnd {
                    builder.discardWorkout()
                    self.onWorkoutDiscarded?()
                } else {
                    builder.finishWorkout { _, error in
                        if let error = error {
                            print("Workout save error:", error)
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

extension SessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ builder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {}
    func workoutBuilderDidCollectEvent(_ builder: HKLiveWorkoutBuilder) {}
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(
            mode: .drill,
            shotType: .layups,
            duration: 60,
            path: .constant(NavigationPath())
        )
    }
}
