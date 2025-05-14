//
//  ContentView.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

enum AppRoute: Hashable {
    case modeSelection
    case shotSelection(mode: SessionMode)
    case challengeDuration(ShotType)
    case session(mode: SessionMode, shot: ShotType, duration: Int?)
    case results(mode: SessionMode, shot: ShotType, duration: Int?, makes: Int, time: Int)
}

// encapsulates which flow we’re in
enum SessionMode: Hashable {
    case freestyle
    case challenge
    case drill
    
    var title: String {
        switch self {
        case .freestyle:  return "Freestyle"
        case .challenge:  return "Challenges"
        case .drill:      return "Drills"
        }
    }
    
    var color: Color {
        switch self {
        case .freestyle:  return .red
        case .challenge:  return .blue
        case .drill:      return .green
        }
    }
    
    var toSessionType: SessionType {
        switch self {
        case .freestyle:  return .freestyle
        case .challenge:  return .challenge
        case .drill:      return .drill
        }
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 15) {
                Text("hoops.")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                NavigationLink(value: AppRoute.modeSelection) {
                    Text("New Session")
                }
                .hapticNavLinkStyle()
                .tint(.green)

                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.orange.opacity(0.75))
                    .padding(.top, 5)
            }
            .offset(y: 95)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .modeSelection:
                    ModeSelection(path: $path)

                case .shotSelection(let mode):
                    // pick shot type for freestyle, challenge, or drill
                    SelectionList(
                        title: mode == .challenge ? "Challenge Type" : (mode == .freestyle ? "Freestyle Type" : "Drill Type"),
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
                    // pick 1,5,10 min
                    SelectionList(
                        title: "Pick Duration",
                        items: [60, 300, 600],
                        label: { "\($0/60) Min" },
                        tint: { duration in
                            switch duration {
                            case 60:  return .red
                            case 300: return .blue
                            default:  return .green
                            }
                        },
                        destination: { duration in
                            AppRoute.session(
                                mode: .challenge,
                                shot: shot,
                                duration: duration
                            )
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
                        path: $path, sessionType: mode.toSessionType,
                        shotType: shot,
                        // for challenges use the countdown left, otherwise show elapsed ‘time’
                        sessionTimeInSec: duration ?? time,
                        makes: makes
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
