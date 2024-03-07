//
//  Session.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI
import Combine

struct Session: View {
    
    @State var startTime = Date()
    @State private var elapsedTime = 0
    @State private var timer: AnyCancellable?
    @State var makes = 0
    @State var sessionEnd = false
    
    //@State private var hapticTimer: Timer?
    //@State var isHapticActive = false
    
    @State var showingEndConfirmation = false
    @State private var showingEndEarlyConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Button {                         showingEndEarlyConfirmation = true
                    } label: {
                        Image(systemName: "x.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.red)
                    }
                    .clipShape(.circle)
                    .frame(width: 25, height: 25)
                    .tint(.red)
                    .confirmationDialog("End Session?", isPresented: $showingEndEarlyConfirmation) {
                                        Button("Finish Session", role: .destructive) {
                                            endSessionAndNavigate()
                                        }
                                        Button("Keep Hoopin'") {
                                            
                                        }
                                    }
                    Spacer()
                    Text(formatTime(seconds: elapsedTime))
                    Spacer()
                    Text("\(makes)")
                    Spacer()
                }
                .padding(.top, 30)
                .font(.system(size: 30))
                .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    makes += 1
                    WKInterfaceDevice.current().play(.directionUp)
                }) {
                    Image(systemName: "basketball")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 125, height: 160)
                }
                .edgesIgnoringSafeArea(.all)
                .tint(.green)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 40))
            }
            .navigationDestination(isPresented: $sessionEnd) {
                PostSession(sessionTimeInSec: elapsedTime, makes: makes)
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

#Preview {
    Session()
}
