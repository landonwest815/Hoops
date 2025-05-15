import SwiftUI
import Combine
import WatchKit

struct SessionView: View {
    let mode: SessionMode
    let shotType: ShotType
    let duration: Int?         // only non‑nil for challenge
    @Binding var path: NavigationPath

    // Common state for “regular” & challenge sessions
    @State private var endDate: Date = .now
    @State private var timeCount: Int = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var makes = 0
    @State private var showingEndEarlyConfirmation = false
    @State private var sessionComplete = false
    @State private var hapticTimer: Timer?
    @StateObject private var sessionManager = SessionManager()

    // Drill‐specific state
    @State private var startTime = Date()
    @State private var elapsedTime = 0
    @State private var drillTimer: AnyCancellable?
    @State private var currentStage = 1
    @State private var stageMakes = 0
    @State private var drillSessionEnd = false
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

    // MARK: — Drill UI (exactly your old code)
    private var drillBody: some View {
        VStack {
            HStack {
                Button {
                    showingDrillEndEarlyConfirmation = true
                } label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(.red)
                }
                .clipShape(.circle)
                .frame(width: 22, height: 22)
                .tint(.red)
                .confirmationDialog(
                    "Abandon Drill?", isPresented: $showingDrillEndEarlyConfirmation
                ) {
                    Button("Quit", role: .destructive) {
                        endDrillSession()
                    }
                    Button("Keep Hoopin'") {}
                }

                Spacer()

                Text(formatTime(seconds: elapsedTime))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)

                Spacer()

                Button {
                    // info action if you want one
                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(.gray)
                }
                .clipShape(.circle)
                .frame(width: 22, height: 22)
                .tint(.gray)
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .font(.system(size: 30))
            .fontWeight(.semibold)

            Spacer()

            LogMakeButton(
              makes: $makes,
              currentStage: $currentStage,
              shotType: shotType
            ) {
              // when all stages complete:
              stopDrillTimer()
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                // push your Results screen onto the path:
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
            if drillTimer == nil {
                startDrillTimer()
            }
        }
        .onDisappear {
            stopDrillTimer()
        }
    }

    // MARK: — Standard / Challenge UI (unchanged)
    private var standardBody: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showingEndEarlyConfirmation = true
                } label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(.red)
                }
                .clipShape(.circle)
                .frame(width: 22, height: 22)
                .tint(.red)
                Spacer()
                Text(TimeFormatter.format(seconds: timeCount))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                Spacer()
                Text("\(makes)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.top, 30)
            .confirmationDialog(
                "Finish session?",
                isPresented: $showingEndEarlyConfirmation,
                titleVisibility: .visible
            ) {
                Button("Keep Hoopin’", role: .cancel) { }
                Button("Finish", role: .destructive) {
                    manualFinish()
                }
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
                    .offset(x: 0, y: 65)
            }
            .edgesIgnoringSafeArea(.all)
            .tint(.green)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 40))
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.container, edges: .top)
        .sheet(isPresented: $sessionComplete) {
            VStack(spacing: 16) {
                Text("Time’s up!")
                    .font(.title2).fontWeight(.bold)
                Text("You made \(makes) shots.")
                    .font(.title3)
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
                .tint(.green).font(.headline)
            }
            .interactiveDismissDisabled(true)
            .navigationBarBackButtonHidden(true)
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
    
    // MARK: — Drill Timer Helpers
    private func startDrillTimer() {
        startTime = Date()
        elapsedTime = 0
        makes = 0
        currentStage = 1
        stageMakes = 0
        drillTimer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                elapsedTime = Int(Date().timeIntervalSince(startTime))
            }
    }
    private func stopDrillTimer() {
        drillTimer?.cancel()
        drillTimer = nil
    }
    private func endDrillSession() {
        stopDrillTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
            drillSessionEnd = true
        }
    }
    private func formatTime(seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: — Standard Timer Helpers & Haptics
    private func startAccurateTimer() {
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
    private func startCountUpTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in timeCount += 1 }
    }
    private func finishSession() {
        stopAllTimers()
        startHapticAlarm()
        sessionComplete = true
    }
    private func manualFinish() {
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
    private func stopAllTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
        sessionManager.endWorkout()
    }
    private func startHapticAlarm() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            WKInterfaceDevice.current().play(.notification)
        }
    }
    private func stopHapticAlarm() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}


import HealthKit

class SessionManager: NSObject, ObservableObject {
  /// Fires when the workout actually ends (either auto or manual).
  var onSessionExpired: (() -> Void)?

  private let healthStore = HKHealthStore()
  private var session: HKWorkoutSession?
  private var builder: HKLiveWorkoutBuilder?

  /// Begin a basketball workout. If `duration` is `nil`, it runs until you call `endWorkout()`.
  func beginWorkout(duration: TimeInterval?) {
    // 1) Create config & session
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

    // 2) Authorize & start
    healthStore.requestAuthorization(
      toShare: [ .workoutType() ],
      read:   [ .workoutType() ]
    ) { ok, err in
      guard ok else { return }
      let start = Date()
      self.session?.startActivity(with: start)
      self.builder?.beginCollection(withStart: start) { _, _ in }

      // 3) If user passed in a duration, auto‑end after that many seconds
      if let dur = duration {
        DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
          self.endWorkout()
        }
      }
    }
  }

  /// Manually end the workout (e.g. user tapped “Finish”).
    func endWorkout() {
      guard let s = session, s.state == .running else { return }
      s.end()
    }
}

// MARK: HKWorkoutSessionDelegate
extension SessionManager: HKWorkoutSessionDelegate {
  func workoutSession(
    _ workoutSession: HKWorkoutSession,
    didChangeTo toState: HKWorkoutSessionState,
    from fromState: HKWorkoutSessionState,
    date: Date
  ) {
    if toState == .ended {
      // once it truly ends, finish collection & fire your callback
      builder?.endCollection(withEnd: date) { _, _ in
        self.builder?.finishWorkout { _, _ in
          DispatchQueue.main.async {
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

// MARK: HKLiveWorkoutBuilderDelegate
extension SessionManager: HKLiveWorkoutBuilderDelegate {
  func workoutBuilder(_ builder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {}
  func workoutBuilderDidCollectEvent(_ builder: HKLiveWorkoutBuilder) {}
}
