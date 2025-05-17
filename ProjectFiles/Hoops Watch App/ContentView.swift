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
    @State private var path = NavigationPath()
    @State private var authStatus: HKAuthorizationStatus?

    private let healthStore = HKHealthStore()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 15) {
                Text("hoops.")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                // While status is undetermined or still loading, show the "Enable" button.
                if authStatus == nil || authStatus == .notDetermined {
                    Button("Enable HealthKit") {
                        requestHealthAuthorization()
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                } else {
                    // Once the user has granted or denied, show "New Session"
                    NavigationLink(value: AppRoute.modeSelection) {
                        Text("New Session")
                    }
                    .hapticNavLinkStyle()
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
            .onAppear(perform: loadAuthorizationStatus)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .modeSelection:
                    ModeSelection(path: $path)

                case .shotSelection(let mode):
                    SelectionList(
                        title: mode == .challenge ? "Challenge Type" : mode.title + " Type",
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
                    SessionView(
                        mode: mode,
                        shotType: shot,
                        duration: duration,
                        path: $path
                    )

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
    }
    
    private func loadAuthorizationStatus() {
       authStatus = healthStore.authorizationStatus(for: .workoutType())
   }

   private func requestHealthAuthorization() {
       guard HKHealthStore.isHealthDataAvailable() else { return }
       let toShare: Set = [ HKObjectType.workoutType() ]
       let toRead:  Set = [ HKObjectType.workoutType() ]
       healthStore.requestAuthorization(toShare: toShare, read: toRead) { success, _ in
           DispatchQueue.main.async {
               authStatus = healthStore.authorizationStatus(for: .workoutType())
           }
       }
   }
}

#Preview {
    ContentView()
}
