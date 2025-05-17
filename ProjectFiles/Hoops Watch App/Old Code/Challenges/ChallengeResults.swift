import SwiftUI

struct ChallengeResults: View {
    @Binding var path: NavigationPath
    @StateObject var watchConnector = WatchToiOSConnector()

    let shotType: ShotType
    let sessionTimeInSec: Int
    let makes: Int

    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 20) {
                VStack {
                    Text("Length")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text(TimeFormatter.format(seconds: sessionTimeInSec))
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                VStack {
                    Text("Makes")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text("\(makes)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }

            VStack(spacing: 20) {
                VStack {
                    Text("Avg/min")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text(averageMakesPerMinute())
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Button("Done") {
                    sendSessionToiOS()
                    path.removeLast(path.count)
                }
                .hapticNavLinkStyle()
                .tint(.green)
                .font(.headline)
            }
        }
        .navigationTitle("Challenge Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    func averageMakesPerMinute() -> String {
        guard sessionTimeInSec > 0 else { return "0.0" }
        let avg = Double(makes) / (Double(sessionTimeInSec) / 60.0)
        return String(format: "%.1f", avg)
    }

    func sendSessionToiOS() {
        let hoopSession = HoopSession(
            date: Date(),
            makes: makes,
            length: sessionTimeInSec,
            shotType: shotType,
            sessionType: .challenge
        )
        watchConnector.sendSessionToiPhone(hoopSession: hoopSession)
    }
}
