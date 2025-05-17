//import SwiftUI
//import Combine
//import WatchKit
//
//struct ChallengeSession: View {
//    var shotType: ShotType
//    @Binding var path: NavigationPath
//    var timeLimit: Int // in seconds
//
//    @State private var endTime: Date = .now
//    @State private var remainingTime: Int = 0
//    @State private var timer: AnyCancellable?
//    @State private var makes = 0
//    @State private var showingEndEarlyConfirmation = false
//    @State private var sessionComplete = false
//    @State private var hapticTimer: Timer?
//
//    @StateObject private var sessionManager = SessionManager()
//
//    var body: some View {
//        VStack {
////            HStack {
////                Spacer()
////
////                Button {
////                    showingEndEarlyConfirmation = true
////                } label: {
////                    Image(systemName: "x.circle")
////                        .resizable()
////                        .frame(width: 22, height: 22)
////                        .foregroundStyle(.red)
////                }
////                .clipShape(.circle)
////                .frame(width: 22, height: 22)
////                .tint(.red)
////                .confirmationDialog("End Session?", isPresented: $showingEndEarlyConfirmation) {
////                    Button("Finish Session", role: .destructive) {
////                        endSessionAndNavigate()
////                    }
////                    Button("Keep Hoopin'") { }
////                }
////
////                Spacer()
////
////                Text(TimeFormatter.format(seconds: remainingTime))
////                    .font(.title2)
////                    .fontWeight(.semibold)
////                    .fontDesign(.rounded)
////
////                Spacer()
////
////                Text("\(makes)")
////                    .font(.title2)
////                    .fontWeight(.semibold)
////                    .fontDesign(.rounded)
////                    .foregroundStyle(.gray)
////
////                Spacer()
////            }
////            .padding(.top, 30)
////
////            Spacer()
////
////            Button(action: {
////                makes += 1
////                WKInterfaceDevice.current().play(.success)
////            }) {
////                Image(systemName: "basketball.fill")
////                    .resizable()
////                    .aspectRatio(contentMode: .fit)
////                    .frame(width: UIConstants.ballIconSize, height: UIConstants.ballIconSize)
////                    .foregroundStyle(.green.opacity(0.35))
////                    .offset(x: 0, y: 65)
////            }
////            .edgesIgnoringSafeArea(.all)
////            .tint(.green)
////            .buttonStyle(.bordered)
////            .buttonBorderShape(.roundedRectangle(radius: 40))
//        }
////        .navigationBarBackButtonHidden()
////        .ignoresSafeArea(.container, edges: .top)
////        .sheet(isPresented: $sessionComplete) {
////            VStack(spacing: 16) {
////                Text("Time’s up!")
////                    .font(.title2)
////                    .fontWeight(.bold)
////
////                Text("You made \(makes) shots.")
////                    .font(.title3)
////
////                Button("View Results") {
////                    stopHapticAlarm()
////                    sessionComplete = false
////                }
////                .tint(.green)
////                .font(.headline)
////            }
////            .interactiveDismissDisabled(true) // <-- this removes the "X"
////            .navigationBarBackButtonHidden(true)
////            .padding()
////        }
////        .onAppear {
////            remainingTime = timeLimit
////            endTime = Date().addingTimeInterval(TimeInterval(timeLimit))
////            startAccurateTimer()
////        }
//    }
//
//    // MARK: - Timer Logic
//
//    func startAccurateTimer() {
//        timer = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { _ in
//                let timeLeft = Int(ceil(endTime.timeIntervalSinceNow))
//                if timeLeft > 0 {
//                    remainingTime = timeLeft
//                } else {
//                    remainingTime = 0
//                   // endSessionAndNavigate()
//                }
//            }
//    }
//
////    func stopTimer() {
////        timer?.cancel()
////        timer = nil
////    }
////
////    func endSessionAndNavigate() {
////        stopTimer()
////        startHapticAlarm()
////        sessionComplete = true
////        sessionManager.end()
////    }
////
////    // MARK: - Haptic Alarm
////
////    func startHapticAlarm() {
////        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
////            WKInterfaceDevice.current().play(.notification)
////        }
////    }
////
////    func stopHapticAlarm() {
////        hapticTimer?.invalidate()
////        hapticTimer = nil
////    }
//}
//
//
////class SessionManager: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {
////    private var session: WKExtendedRuntimeSession?
////    var onSessionExpired: (() -> Void)?
////
////    func begin(duration: TimeInterval) {
////        session = WKExtendedRuntimeSession()
////        session?.delegate = self
////        session?.start()
////
////        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
////            self.triggerExpiration()
////        }
////    }
////
////    func end() {
////        session?.invalidate()
////        session = nil
////    }
////
////    private func triggerExpiration() {
////        WKInterfaceDevice.current().play(.notification)
////        onSessionExpired?()
////    }
////
////    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
////    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
////    func extendedRuntimeSessionDidInvalidate(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
////    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
////                                 didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
////                                 error: Error?) {}
////}
