//
//  CourtView.swift
//  Hoops Watch App
//
//  Created by Landon West on 2/11/25.
//

import SwiftUI
import Combine

struct DrillView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var startTime = Date()
    @State private var elapsedTime = 0
    @State private var timer: AnyCancellable?
    @State var makes = 0
    @State var sessionEnd = false
    
    @State var showingEndConfirmation = false
    @State private var showingEndEarlyConfirmation = false
    
    @State var currentStage = 1
    @State var shotType: ShotType
        
    var body: some View {
        NavigationStack {
            
            VStack {
                    
                HStack {
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
                    .confirmationDialog(
                        "Abandon Drill?", isPresented: $showingEndEarlyConfirmation) {
                            Button("Quit", role: .destructive) {
                                endSessionAndNavigate()
                            }
                            Button("Keep Hoopin'") {
                                
                            }
                        }
                    
                    Spacer()
                    
                    Text(formatTime(seconds: elapsedTime))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                    
                    Spacer()
                    
                    Button {
                        // show the shot chart location
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
                
                LogMakeButton(makes: $makes, currentStage: $currentStage, shotType: shotType, onComplete: { endSessionAndNavigate() })
                
            }
            .navigationDestination(isPresented: $sessionEnd) {
                DrillResults(shotType: shotType, sessionTimeInSec: elapsedTime, makes: makes)
                    .navigationBarBackButtonHidden()
                    .navigationBarTitleDisplayMode(.inline)
                        }
            .onAppear {
                if (timer == nil) {
                    startTimer()
                }
            }
            .edgesIgnoringSafeArea(.all)
        
        }
    }

    func endSessionAndNavigate() {
        stopTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
            sessionEnd = true
        }
    }
    
    func startTimer() {
        // Capture the start time
        startTime = Date()
        elapsedTime = 0
        makes = 0
        // Create a timer that updates the elapsed time
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            self.updateElapsedTime()
        }
    }

    func stopTimer() {
        // Invalidate and release the timer
        timer?.cancel()
        timer = nil
    }

    func updateElapsedTime() {
        let currentTime = Date()
        // Calculate the elapsed time by comparing the current time with the start time
        elapsedTime = Int(currentTime.timeIntervalSince(startTime))
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
}



struct CourtLines: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                
                if true {
                    // Draw the center circle
                    Path { path in
                        path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2.75), radius: geometry.size.width / 7, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                    }
                    .stroke(Color.green.opacity(0.5), lineWidth: 5)
                    .offset(x: 0, y: geometry.size.height / 8)
                    
                    // Three-point line
                    Path { path in
                        path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                    }
                    .stroke(Color.green.opacity(0.5), lineWidth: 5)
                    
                    // Free-throw lane
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width / 2.8, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width / 2.8, y: geometry.size.height / 2))
                        path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: geometry.size.height / 2))
                        path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: 0))
                    }
                    .stroke(Color.green.opacity(0.5), lineWidth: 5)
                    
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: geometry.size.height / 3.8))
                    }
                    .stroke(Color.green.opacity(0.5), lineWidth: 5)
                    
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: geometry.size.height / 3.8))
                    }
                    .stroke(Color.green.opacity(0.5), lineWidth: 5)
                }
                
            }
            
            Image(systemName: "circle.fill")
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .offset(x: -50, y: -50)
        }
        .aspectRatio(1.15, contentMode: .fit)
        .frame(height: 175)
    }
    
    
}

#Preview {
    DrillView(shotType: .deep)
}
