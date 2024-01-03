//
//  Session.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct Session: View {
    
    @State var sessionTime: Int
    @State var copiedTime: Int
    @State var makes = 0
    @State var sessionEnd = false
    
    @State var timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
    @State private var hapticTimer: Timer?
    @State var isHapticActive = false
    
    @State var showingEndConfirmation = false
    @State private var showingEndEarlyConfirmation = false

    // copy over the time to save it's initial value
    init(sessionTime: Int) {
            self._sessionTime = State(initialValue: sessionTime)
            self._copiedTime = State(initialValue: sessionTime)
    }
    
    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "x.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.red)
                    }
                    .clipShape(.circle)
                    .frame(width: 25, height: 25)
                    .tint(.red)
                    .simultaneousGesture(TapGesture().onEnded{
                        showingEndEarlyConfirmation = true
                    })
                    .confirmationDialog("End Session Early?",
                                        isPresented: $showingEndEarlyConfirmation) {
                        NavigationLink(destination: PostSession(sessionTimeInMin: copiedTime, makes: makes).navigationBarBackButtonHidden(true)            .navigationBarTitleDisplayMode(.inline)) {
                            Button("End", role: .destructive) {
                                WKInterfaceDevice.current().play(.click)
                                sessionEnd = true
                            }
                        }
                        .tint(.red)
                    }
                    Spacer()
                    Text(formatTime(seconds: sessionTime))
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
            .onReceive(timer) { time in
                if sessionTime > 0 {
                    sessionTime -= 1
                } else {
                    startHapticFeedback()
                    showingEndConfirmation = true
                    self.timer.upstream.connect().cancel()
                }
            }
            .edgesIgnoringSafeArea(.all)
            .confirmationDialog("End of Session",
                                isPresented: $showingEndConfirmation) {
                NavigationLink(destination: PostSession(sessionTimeInMin: copiedTime, makes: makes).navigationBarBackButtonHidden(true)            .navigationBarTitleDisplayMode(.inline)) {
                    Button("Exit", role: .destructive) {
                        startHapticFeedback()
                        WKInterfaceDevice.current().play(.click)
                        sessionEnd = true
                    }
                }
                .tint(.red)
            }
            .onDisappear {
                stopHapticFeedback()
            }
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func startHapticFeedback() {
           isHapticActive = true
           hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
               if self.isHapticActive {
                   WKInterfaceDevice.current().play(.notification)
               } else {
                   self.hapticTimer?.invalidate()
               }
           }
   }

   func stopHapticFeedback() {
       isHapticActive = false
       hapticTimer?.invalidate()
   }
    
}

#Preview {
    Session(sessionTime: 120)
}
