//
//  PostSession 2.swift
//  Hoops
//
//  Created by Landon West on 2/13/25.
//

import SwiftUI

struct DrillResults: View {
    @StateObject var watchConnector = WatchToiOSConnector()
    @Environment(\.dismiss) private var dismiss
    
    var shotType: ShotType
    
    @State var sessionTimeInSec: Int
    @State var makes: Int

    var body: some View {
        
        NavigationView {
            HStack(spacing: 20) {
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack {
                        
                        Text("Time")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.gray)
                        
                        Text(formatTime(seconds: sessionTimeInSec))
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        
                    }
                    
                    VStack {
                        
                        Button("Done") {
                            sendSessionToiOS()
                            dismiss()
                        }
                        .simultaneousGesture(TapGesture().onEnded{
                            WKInterfaceDevice.current().play(.click)
                        })
                        .tint(.green)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                    }
                }
                .navigationBarBackButtonHidden(true)

            }
            .navigationTitle("Session Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear() {
            sessionTimeInSec = 0
            makes = 0
        }
        
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func averageMakesPerMinute(sessionLength: Int, makes: Int) -> String {
        guard sessionLength > 0 else { return "0.0" }

        let average = Double(makes) / (Double(sessionLength) / 60.0)
        return String(format: "%.1f", round(10 * average) / 10)
    }
    
    func sendSessionToiOS() {
        let hoopSession = HoopSession(date: Date.now, makes: makes, length: sessionTimeInSec, shotType: shotType, sessionType: .drill)
        watchConnector.sendSessionToiPhone(hoopSession: hoopSession)
    }
}

#Preview {
    DrillResults(shotType: .allShots, sessionTimeInSec: 600, makes: 25)
}
