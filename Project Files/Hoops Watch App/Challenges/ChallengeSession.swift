import SwiftUI
import Combine

struct ChallengeSession: View {
    
    var shotType: ShotType
    var timeLimit: Int // in seconds
    
    @State private var remainingTime = 0
    @State private var timer: AnyCancellable?
    @State var makes = 0
    @State var sessionEnd = false
    @State private var showingEndEarlyConfirmation = false
    
    @State private var sessionComplete = false
    @State private var hapticTimer: Timer? = nil

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
                            Button("Keep Hoopin'") { }
                        }
                    
                    Spacer()
                    
                    Text(formatTime(seconds: remainingTime))
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
                
                Spacer()
                
                Button(action: {
                    makes += 1
                    WKInterfaceDevice.current().play(.success)
                }) {
                    VStack(spacing: 10) {
                        Image(systemName: "basketball.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .foregroundStyle(.green.opacity(0.35))
                    }
                    .offset(x: 0, y: 65)
                }
                .edgesIgnoringSafeArea(.all)
                .tint(.green)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 40))
            }
            .sheet(isPresented: $sessionComplete) {
                VStack(spacing: 16) {
                    Text("Time’s up!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You made \(makes) shots.")
                        .font(.title3)
                    
                    Button("View Results") {
                        stopHapticAlarm()
                        sessionEnd = true
                        sessionComplete = false
                    }
                    .tint(.green)
                    .font(.headline)
                }
                .padding()
            }
            .navigationDestination(isPresented: $sessionEnd) {
                ChallengeResults(
                    shotType: shotType,
                    sessionTimeInSec: timeLimit,
                    makes: makes
                )
                .navigationBarBackButtonHidden()
            }
            .onAppear {
                if timer == nil {
                    remainingTime = timeLimit
                    startTimer()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    endSessionAndNavigate()
                }
            }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func endSessionAndNavigate() {
        stopTimer()
        sessionComplete = true
        startHapticAlarm()
    }
    
    func startHapticAlarm() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            WKInterfaceDevice.current().play(.notification) // or .retry / .failure
        }
    }
    
    func stopHapticAlarm() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
