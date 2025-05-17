//
//  ResultsView.swift
//  Hoops
//
//  Created by Landon West on 5/14/25.
//

import SwiftUI

struct ResultsView: View {
    @Binding var path: NavigationPath
    @StateObject private var watchConnector = WatchToiOSConnector()

    let sessionType: SessionType
    let shotType: ShotType
    let sessionTimeInSec: Int
    let makes: Int

    var body: some View {
        HStack(spacing: 20) {
            // ←——————————————————————— Time & Makes column
            VStack(spacing: 20) {
                VStack {
                    Text("Length")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text(formatTime(sessionTimeInSec))
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

            // ←——————————————————————— Avg/min & Done column
            VStack(spacing: 20) {
                VStack {
                    Text("Avg/min")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text(String(format: "%.1f", averageMakesPerMinute))
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Button("Done") {
                    sendSessionToiPhone()
                    path = NavigationPath()
                }
                .tint(.green)
            }
        }
        .navigationTitle("\(sessionType.rawValue) Stats")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .padding()
    }

    // MARK: – Helpers

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private var averageMakesPerMinute: Double {
        guard sessionTimeInSec > 0 else { return 0 }
        return Double(makes) / (Double(sessionTimeInSec) / 60.0)
    }

    private func sendSessionToiPhone() {
        let session = HoopSession(
            date: Date(),
            makes: makes,
            length: sessionTimeInSec,
            shotType: shotType,
            sessionType: sessionType
        )
        watchConnector.sendSessionToiPhone(hoopSession: session)
    }
}
