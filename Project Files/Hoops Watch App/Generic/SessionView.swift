//
//  SessionView.swift
//  Hoops
//
//  Created by Landon West on 5/14/25.
//


// SessionView.swift
import SwiftUI
import Combine
import WatchKit

struct SessionView: View {
    let mode: SessionMode
    let shotType: ShotType
    let duration: Int?       // only non‑nil for challenge
    @Binding var path: NavigationPath

    @State private var timeCount = 0
    @State private var makes = 0
    @State private var showingEndEarlyConfirmation = false
    @State private var sessionComplete = false
    @State private var timerCancellable: AnyCancellable?
    @State private var hapticTimer: Timer?

    var body: some View {
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
                
                Spacer()
                
                Text(TimeFormatter.format(seconds: timeCount))
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
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.container, edges: .top)
        .alert("Finish Session?", isPresented: $showingEndEarlyConfirmation) {
            Button("Keep Going", role: .cancel) { }
            Button("Finish", role: .destructive) { manualFinish() }
        }
        .sheet(isPresented: $sessionComplete) {
            VStack(spacing: 16) {
                Text("Done!")
                    .font(.title2).bold()
                Text("You made \(makes) shots in \(TimeFormatter.format(seconds: timeCount)).")
                Button("View Results") {
                    path.append(
                        AppRoute.results(
                            mode: mode,
                            shot: shotType,
                            duration: duration,
                            makes: makes,
                            time: timeCount
                        )
                    )
                    sessionComplete = false
                }
            }
            .padding()
            .interactiveDismissDisabled(mode == .challenge)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimers()
        }
    }

    // MARK: - Timer

    func startTimer() {
        if mode == .challenge, let limit = duration {
            timeCount = limit
            // count DOWN
            timerCancellable = Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if timeCount > 0 {
                        timeCount -= 1
                    } else {
                        finishSession()
                    }
                }
            // haptic alarm every second once done
        } else {
            timeCount = 0
            // count UP
            timerCancellable = Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    timeCount += 1
                }
        }
    }

    private func manualFinish() {
        stopTimers()
        path.append(
          AppRoute.results(
            mode: mode,
            shot: shotType,
            duration: duration,
            makes: makes,
            time: timeCount
          )
        )
      }

      private func finishSession() {
        stopTimers()
        if mode == .challenge {
          hapticTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            _ in WKInterfaceDevice.current().play(.notification)
          }
        }
        sessionComplete = true    // ← shows your sheet
      }
    
    func stopTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}
