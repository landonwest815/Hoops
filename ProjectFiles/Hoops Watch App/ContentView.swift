import SwiftUI
import HealthKit

enum AppRoute: Hashable {
    case modeSelection
    case shotSelection(mode: SessionMode)
    case challengeDuration(ShotType)
    case session(mode: SessionMode, shot: ShotType, duration: Int?)
    case results(mode: SessionMode, shot: ShotType, duration: Int?, makes: Int, time: Int)
}

enum SessionMode: Hashable {
    case freestyle, challenge, drill

    var title: String {
        switch self {
        case .freestyle: return "Freestyle"
        case .challenge: return "Challenges"
        case .drill:     return "Drills"
        }
    }

    var color: Color {
        switch self {
        case .freestyle: return .red
        case .challenge: return .blue
        case .drill:     return .green
        }
    }

    var toSessionType: SessionType {
        switch self {
        case .freestyle: return .freestyle
        case .challenge: return .challenge
        case .drill:     return .drill
        }
    }
}

struct ContentView: View {
    @Binding var path: NavigationPath

    @State private var hasWorkoutPermission = false
    private let healthStore = HKHealthStore()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 15) {
                Text("hoops.")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                if hasWorkoutPermission {
                    NavigationLink(value: AppRoute.modeSelection) {
                        Text("New Session")
                    }
                    .hapticNavLinkStyle()
                    .tint(.green)
                } else {
                    Button("Enable HealthKit") {
                        requestWorkoutAuthorization()
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }

                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.orange.opacity(0.75))
                    .padding(.top, 5)
                    .offset(x: 10, y: -5)
            }
            .offset(y: 95)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .modeSelection:
                    ModeSelection(path: $path)
                case .shotSelection(let mode):
                    SelectionList(
                        title: mode.title + " Type",
                        items: ShotType.allCases,
                        label: { $0.displayName },
                        tint: { $0.color },
                        destination: { shot in
                            mode == .challenge
                                ? AppRoute.challengeDuration(shot)
                                : AppRoute.session(mode: mode, shot: shot, duration: nil)
                        },
                        path: $path
                    )
                case .challengeDuration(let shot):
                    SelectionList(
                        title: "Pick Duration",
                        items: [60, 300, 600],
                        label: { "\($0 / 60) Min" },
                        tint: {
                            switch $0 {
                            case 60:  return .red
                            case 300: return .blue
                            default:  return .green
                            }
                        },
                        destination: { duration in
                            AppRoute.session(mode: .challenge, shot: shot, duration: duration)
                        },
                        path: $path
                    )
                case .session(let mode, let shot, let duration):
                    SessionView(mode: mode, shotType: shot, duration: duration, path: $path)
                case .results(let mode, let shot, let duration, let makes, let time):
                    ResultsView(
                        path: $path,
                        sessionType: mode.toSessionType,
                        shotType: shot,
                        sessionTimeInSec: duration ?? time,
                        makes: makes
                    )
                }
            }
        }
        .onAppear(perform: checkWorkoutPermission)
    }

    private func checkWorkoutPermission() {
        guard HKHealthStore.isHealthDataAvailable() else {
            hasWorkoutPermission = false
            return
        }
        let status = healthStore.authorizationStatus(for: .workoutType())
        hasWorkoutPermission = (status == .sharingAuthorized)
        print("🔍 workoutType status = \(status.rawValue) (\(status)), hasWorkoutPermission = \(hasWorkoutPermission)")
    }

    private func requestWorkoutAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit not available")
            return
        }

        let toShare: Set<HKSampleType> = [.workoutType()]

        var toRead: Set<HKObjectType> = [.workoutType()]
        if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            toRead.insert(hr)
        }
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            toRead.insert(energy)
        }

        print("🔹 Requesting HealthKit permissions…")
        healthStore.requestAuthorization(toShare: toShare, read: toRead) { success, error in
            DispatchQueue.main.async {
                print("🔸 workoutType auth callback – success: \(success), error: \(String(describing: error))")
                self.hasWorkoutPermission = success
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    ContentView(path: $path)
}
