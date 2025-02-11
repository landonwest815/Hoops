//
//  CourtView.swift
//  Hoops Watch App
//
//  Created by Landon West on 2/11/25.
//

import SwiftUI
import Combine

struct DrillView: View {
    
    @State var startTime = Date()
    @State private var elapsedTime = 0
    @State private var timer: AnyCancellable?
    @State var makes = 0
    @State var sessionEnd = false
    
    @State var showingEndConfirmation = false
    @State private var showingEndEarlyConfirmation = false
        
    var body: some View {
        NavigationStack {
            
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
                    .confirmationDialog(
                        "End Session?", isPresented: $showingEndEarlyConfirmation) {
                            Button("Finish Session", role: .destructive) {
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
                    
                    Text("\(makes)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                }
                .padding(.top, 30)
                .font(.system(size: 30))
                .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    makes += 1
                    WKInterfaceDevice.current().play(.success)
                }) {
                    VStack(spacing: 5) {
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green.opacity(0.75))
                                
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green.opacity(0.75))
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green.opacity(0.25))
                                
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green.opacity(0.25))
                            
                            Image(systemName: "basketball.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green.opacity(0.25))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 0) {
                            Text("Left Corner Three")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.green.opacity(1))
                            
//                                Text("x5")
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .fontDesign(.rounded)
//                                    .foregroundStyle(.green.opacity(0.5))
                        }
                        
                        Spacer()
                        
                    }
                    
                }
                .edgesIgnoringSafeArea(.all)
                .tint(.green)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 40))
            }
            .navigationDestination(isPresented: $sessionEnd) {
                PostSession(shotType: .allShots, sessionTimeInSec: elapsedTime, makes: makes)
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
        sessionEnd = true
        stopTimer()
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
    DrillView()
}
